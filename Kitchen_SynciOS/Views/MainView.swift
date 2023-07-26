import SwiftUI
import CoreData

struct MainView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ListNode.timestamp, ascending: true)],
        animation: .default)
    private var listNodes: FetchedResults<ListNode>
    
    @State private var showingAddNodeModal = false
    @State private var newNodeTitle = ""
    @State private var showingEditNodePopover = false
    @State private var showingAddItemPopover = false
    @State private var nodeToEdit: ListNode? = nil
    @State private var nodeToAddItem: ListNode? = nil
    @State private var editedNodeTitle = ""
    @State private var newItemTitle = ""
    
    @State private var groceryStores: [MKMapItem] = []


    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEach(listNodes) { listNode in
                    VStack {
                        HStack {
                            Text(listNode.title ?? "")
                                .font(.headline)
                                .padding()
                            Spacer()
                            Button(action: {
                                nodeToAddItem = listNode
                                showingAddItemPopover = true
                            }) {
                                Image(systemName: "plus")
                            }
                            .popover(isPresented: $showingAddItemPopover) {
                                Form {
                                    TextField("Item Title", text: $newItemTitle)
                                    Button("Add Item") {
                                        addItem(to: nodeToAddItem)
                                        showingAddItemPopover = false
                                    }
                                }
                                .padding()
                            }
                        }
                        Divider()
                        ForEach(Array(listNode.items as? Set<ListItem> ?? []), id: \.self) { item in
                            ListItemView(item: item)
                        }
                        .onDelete(perform: deleteItems)
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding()
                    .contextMenu {
                        Button(action: {
                            nodeToEdit = listNode
                            editedNodeTitle = listNode.title ?? ""
                            showingEditNodePopover = true
                        }) {
                            Text("Edit Node Title")
                            Image(systemName: "pencil")
                        }
                        Button(action: {
                            deleteNode(listNode)
                        }) {
                            Text("Delete Node")
                            Image(systemName: "trash")
                        }
                    }
                    .popover(isPresented: $showingEditNodePopover) {
                        Form {
                            TextField("Node Title", text: $editedNodeTitle)
                            Button("Save") {
                                if let nodeToEdit = nodeToEdit {
                                    nodeToEdit.title = editedNodeTitle
                                    do {
                                        try viewContext.save()
                                    } catch {
                                        // Handle the error
                                    }
                                }
                                showingEditNodePopover = false
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem {
                Button(action: { showingAddNodeModal = true }) {
                    Label("Add Node", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddNodeModal) {
                  AddNodeView(isShowing: $showingAddNodeModal, newNodeTitle: $newNodeTitle, addNodeAction: addNode)
              }
    }
    
    private func addNode() {
        withAnimation {
            let newNode = ListNode(context: viewContext)
            newNode.timestamp = Date()
            newNode.title = newNodeTitle

            do {
                try viewContext.save()
                newNodeTitle = "" // Reset the title for the next node
            } catch {
                // Handle the error
            }
        }
    }
    
    private func addItem(to node: ListNode?) {
        withAnimation {
            if let node = node {
                let newItem = ListItem(context: viewContext)
                newItem.title = newItemTitle
                newItem.isTapped = false
                newItem.listNode = node

                do {
                    try viewContext.save()
                    newItemTitle = "" // Reset the title for the next item
                } catch {
                    // Handle the error
                }
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { Array(listNodes[$0].items as? Set<ListItem> ?? Set<ListItem>())[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Handle error
            }
        }
    }
    
    private func deleteNode(_ node: ListNode) {
        withAnimation {
            // Delete all items associated with the node
            let items = Array(node.items as? Set<ListItem> ?? [])
            items.forEach(viewContext.delete)
            
            // Delete the node itself
            viewContext.delete(node)

            do {
                try viewContext.save()
            } catch {
                // Handle error
            }
        }
    }
}


struct AddItemView: View {
    @Binding var isShowing: Bool
    @Binding var title: String
    let addItemAction: () -> Void

    var body: some View {
        VStack {
            Text("Add a new item")
                .font(.headline)

            TextField("Title", text: $title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                addItemAction()
                isShowing = false
            }) {
                Text("Add Item")
            }
            .padding()
        }
        .frame(width: 300, height: 200)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 20)
    }
}

struct AddNodeView: View {
    @Binding var isShowing: Bool
    @Binding var newNodeTitle: String
    let addNodeAction: () -> Void
    @State var selectedGroceryStore = ""
    @State var groceryStores: [String] = [] // This will hold the names of the grocery stores

    var body: some View {
            ZStack {
                Color.clear
                    .onTapGesture {
                        isShowing = false
                    }
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text("Add Node")
                        .font(.headline)
                    Picker(selection: $newNodeTitle, label: Text("Select Grocery Store").font(.headline).foregroundColor(.blue)) {
                        ForEach(groceryStores, id: \.self) { store in
                            Text(store).tag(store)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .padding()
                    Button("Add") {
                        addNodeAction()
                        isShowing = false
                    }
                    .padding()
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 5)
            }
            .onAppear {
                findGroceryStores()
            }
        }

    func findGroceryStores() {
        // Create a search request
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "Grocery Stores"

        // Initialize the search
        let search = MKLocalSearch(request: request)

        // Start the search
        search.start { (response, error) in
            guard let response = response else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            // Update the groceryStores array with the names of the grocery stores
            self.groceryStores = response.mapItems.map { $0.name ?? "" }
        }
    }
}


struct ListItemView: View {
    @ObservedObject var item: ListItem
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        HStack {
            // Circle that is filled if the item is tapped
            Circle()
                .fill(item.isTapped ? Color.green : Color.red)
                .frame(width: 20, height: 20)
                .onTapGesture {
                    withAnimation {
                        item.isTapped.toggle()
                        do {
                            try viewContext.save()
                            print("Successfully saved context after updating isTapped.")
                        } catch {
                            print("Failed to save context after updating isTapped. Error: \(error)")
                        }
                    }
                }

            Text(item.title ?? "No Title") // Use "No Title" if title is nil
        }
        .padding()
        .contextMenu {
            Button(action: {
                viewContext.delete(item)
                do {
                    try viewContext.save()
                } catch {
                    print("Failed to save context after deleting item. Error: \(error)")
                }
            }) {
                Text("Delete")
                Image(systemName: "trash")
            }
        }
    }
}

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @Binding var groceryStores: [MKMapItem]

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        updateAnnotations(from: uiView)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    private func updateAnnotations(from mapView: MKMapView) {
        mapView.removeAnnotations(mapView.annotations)
        let annotations = self.groceryStores.map(GroceryStoreAnnotation.init)
        mapView.addAnnotations(annotations)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var map: MapView

        init(_ map: MapView) {
            self.map = map
        }
    }
}

final class GroceryStoreAnnotation: NSObject, MKAnnotation {
    let title: String?
    let coordinate: CLLocationCoordinate2D

    init(groceryStore: MKMapItem) {
        self.title = groceryStore.name
        self.coordinate = groceryStore.placemark.coordinate
        super.init()
    }
}
