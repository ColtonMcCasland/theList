import SwiftUI
import CoreData
import UniformTypeIdentifiers

struct MainView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Store.name, ascending: true)],
        animation: .default)
    private var stores: FetchedResults<Store>
    @AppStorage("isLoggedIn") private var isLoggedIn = true
    @State private var showingActionSheet = false

    @State private var newItemName = ""
    @State private var newStoreName = ""

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(stores, id: \.self) { store in
                        Section(header: Text(store.name ?? "Unspecified")) {
                            ForEach(store.itemsArray, id: \.self) { item in
                                DraggableCellView(item: item)
                                    .onDrop(of: [UTType.data.identifier], delegate: DropDelegate(viewContext: viewContext, store: store))
                            }

                            .onDelete(perform: { indexSet in
                                deleteItem(at: indexSet, from: store)
                            })
                        }
                    }
                }
            
                VStack {
                    Button(action: {
                        addItemAndStore()
                    }) {
                        Text("Add")
                    }.disabled(newItemName.isEmpty && newStoreName.isEmpty) // Disable the button when both fields are empty
            
                    HStack {
                        Image(systemName: "cart.fill") // Icon for item
                        TextField("Enter item name", text: $newItemName)
                    }
                    HStack {
                        Image(systemName: "building.columns.fill") // Icon for store
                        TextField("Enter store name", text: $newStoreName)
                    }
                }
                .padding()
            }
            .navigationBarItems(trailing:
                Button(action: {
                    showingActionSheet = true
                }) {
                    Image(systemName: "ellipsis.circle")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                .actionSheet(isPresented: $showingActionSheet) {
                    ActionSheet(title: Text("Options"), buttons: [
                        .default(Text("Log Out"), action: logOut),
                        .cancel()
                    ])
                }
            )
        }
        .navigationBarTitle("Grocery List", displayMode: .inline)
    }
    
    struct DropDelegate: SwiftUI.DropDelegate {
        var viewContext: NSManagedObjectContext
        var store: Store

        func performDrop(info: DropInfo) -> Bool {
            guard let itemProvider = info.itemProviders(for: [UTType.data.identifier]).first else { return false }
            itemProvider.loadDataRepresentation(forTypeIdentifier: UTType.data.identifier) { (data, error) in
                guard let data = data, let itemData = try? JSONDecoder().decode(ItemData.self, from: data) else { return }
                DispatchQueue.main.async {
                    let fetchRequest: NSFetchRequest<GroceryItem> = GroceryItem.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "id == %@", itemData.id as CVarArg)
                    if let items = try? viewContext.fetch(fetchRequest), let item = items.first {
                        item.store = store
                        do {
                            try viewContext.save()
                        } catch {
                            let nserror = error as NSError
                            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                        }
                    }
                }
            }
            return true
        }
    }





    private func logOut() {
        // Perform any necessary log out actions here...

        // Then set isLoggedIn to false to return to the ICloudLoginView
        isLoggedIn = false
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
    }

    func addItemAndStore() {
        let store: Store
        if !newStoreName.isEmpty {
            // Check if a store with the given name already exists
            if let existingStore = stores.first(where: { $0.name == newStoreName }) {
                // If it does, use that store
                store = existingStore
            } else {
                // If not, create a new store
                store = Store(context: viewContext)
                store.name = newStoreName
            }
        } else {
            // If no store name was provided, create a new store with a default name
            store = Store(context: viewContext)
            store.name = "Unspecified"
        }

        if !newItemName.isEmpty {
            let newItem = GroceryItem(context: viewContext)
            newItem.name = newItemName
            newItem.store = store
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

    func deleteItem(at offsets: IndexSet, from store: Store) {
        for index in offsets {
            let item = store.itemsArray[index]
            viewContext.delete(item)
        }
        do {
            try viewContext.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }

        // Check if the store has any items left
        if store.itemsArray.isEmpty {
            // If not, delete the store
            viewContext.delete(store)
            do {
                try viewContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func deleteStore(store: Store) {
        viewContext.delete(store)
        do {
            try viewContext.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    struct DraggableCellView: View {
        var item: GroceryItem
        @State private var isDragOver = false

        var body: some View {
            ZStack {
                if isDragOver {
                    // This is the appearance of the cell when a drag operation is over it.
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.5))
                } else {
                    // This is the normal appearance of the cell.
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                }
                Text(item.name ?? "Unnamed")
            }
            .frame(height: 50)
            .onDrag {
                let itemData = ItemData(id: item.id ?? UUID(), name: item.name ?? "", storeName: item.store?.name ?? "")
                let encoder = JSONEncoder()
                if let data = try? encoder.encode(itemData) {
                    return NSItemProvider(item: data as NSData, typeIdentifier: UTType.data.identifier)
                } else {
                    return NSItemProvider()
                }
            }

            .onDrop(of: [UTType.data.identifier], isTargeted: $isDragOver) { providers, location in
                // You might want to handle the drop here, or you might handle it in the onDrop of the parent view.
                false
            }
        }
    }

    
    
}

extension Store {
    // Computed property to return the items of a store as an array
    var itemsArray: [GroceryItem] {
        let set = items as? Set<GroceryItem> ?? []
        return set.sorted {
            $0.name ?? "" < $1.name ?? ""
        }
    }
}

struct ItemData: Codable {
    var id: UUID
    var name: String
    var storeName: String
}

