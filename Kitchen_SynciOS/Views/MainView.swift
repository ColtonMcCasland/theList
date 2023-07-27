import SwiftUI
import CoreData

struct MainView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Store.name, ascending: true)],
        animation: .default)
    private var stores: FetchedResults<Store>

    @State private var newItemName = ""
    @State private var newStoreName = ""

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(stores, id: \.self) { store in
                        Section(header: HStack {
                            Text(store.name ?? "Unspecified")
                        }) {
                            ForEach(store.itemsArray, id: \.self) { item in
                                Text(item.name ?? "Unnamed")
                                // Implement drag and drop functionality here
                            }
                            .onDelete(perform: { indexSet in
                                deleteItem(at: indexSet, from: store)
                            })
                        }
                    }
                }
                
                VStack {
                    HStack {
                        Image(systemName: "cart.fill") // Icon for item
                        TextField("Enter item name", text: $newItemName)
                    }
                    HStack {
                        Image(systemName: "building.columns.fill") // Icon for store
                        TextField("Enter store name", text: $newStoreName)
                    }
                    Button(action: {
                        addItemAndStore()
                    }) {
                        Text("Add")
                    }
                }
                .padding()
                .background(Color.yellow)
            }
        }
        .navigationBarTitle("Grocery List", displayMode: .inline)

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
