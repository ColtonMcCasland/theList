import SwiftUI
import CoreData

struct MainView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \GroceryItem.name, ascending: true)],
        animation: .default)
    private var items: FetchedResults<GroceryItem>

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Store.name, ascending: true)],
        animation: .default)
    private var stores: FetchedResults<Store>

    @State private var newItemName = ""
    @State private var newStoreName = ""

    var body: some View {
        VStack {
            ForEach(stores, id: \.self) { store in
                DraggableList(store: store, items: Binding(get: {
                    Array(self.items.filter { $0.store == store })
                }, set: { (newItems) in
                    for item in newItems {
                        item.store = store
                    }
                }))
            }
            
            VStack {
                TextField("Enter item name", text: $newItemName)
                TextField("Enter store name", text: $newStoreName)
                Button(action: {
                    addItemAndStore()
                }) {
                    Text("Add")
                }
            }
            .padding()
        }
    }

    func addItemAndStore() {
        let newStore: Store
        if !newStoreName.isEmpty {
            newStore = Store(context: viewContext)
            newStore.name = newStoreName
        } else {
            newStore = Store(context: viewContext)
            newStore.name = "Unspecified"
        }

        if !newItemName.isEmpty {
            let newItem = GroceryItem(context: viewContext)
            newItem.name = newItemName
            newItem.store = newStore
        }

        do {
            try viewContext.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }

        newItemName = ""
        newStoreName = ""
    }
}

struct DraggableList: UIViewRepresentable {
    var store: Store
    @Binding var items: [GroceryItem]

    func makeUIView(context: Context) -> UITableView {
        let tableView = UITableView()
        tableView.dataSource = context.coordinator
        tableView.delegate = context.coordinator
        tableView.dragDelegate = context.coordinator
        tableView.dropDelegate = context.coordinator
        tableView.dragInteractionEnabled = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return tableView
    }

    func updateUIView(_ uiView: UITableView, context: Context) {
        uiView.reloadData()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITableViewDataSource, UITableViewDelegate, UITableViewDragDelegate, UITableViewDropDelegate {
        var parent: DraggableList

        init(_ parent: DraggableList) {
            self.parent = parent
        }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return parent.items.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = parent.items[indexPath.row].name
            return cell
        }

        func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
            let item = parent.items[indexPath.row]
            let itemProvider = NSItemProvider(object: item.id.uuidString as NSString)
            let dragItem = UIDragItem(itemProvider: itemProvider)
            dragItem.localObject = item
            return [dragItem]
        }

        func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
            let destinationIndexPath: IndexPath
            if let indexPath = coordinator.destinationIndexPath {
                destinationIndexPath = indexPath
            } else {
                let row = tableView.numberOfRows(inSection: 0)
                destinationIndexPath = IndexPath(row: row, section: 0)
            }

            coordinator.session.loadObjects(ofClass: NSString.self) { items in
                if let idString = items.first as? String, let uuid = UUID(uuidString: idString) {
                    DispatchQueue.main.async {
                        let sourceIndex = self.parent.items.firstIndex(where: { $0.id == uuid })!
                        let item = self.parent.items.remove(at: sourceIndex)
                        self.parent.items.insert(item, at: destinationIndexPath.row)
                        item.store = self.parent.store
                        do {
                            try self.parent.viewContext.save()
                        } catch {
                            let nserror = error as NSError
                            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                        }
                    }
                }
            }
        }

        func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
            return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
    }
}
