import SwiftUI
import MobileCoreServices

struct MainView: View {
    @State private var groceryItems = [GroceryItem(name: "Milk", store: "Store 1"), GroceryItem(name: "Bread", store: "Store 1"), GroceryItem(name: "Eggs", store: "Store 2")]
    @State private var newItemName = ""
    @State private var newStoreName = ""
    @State private var stores = ["Store 1", "Store 2", "Store 3"]

    var body: some View {
        VStack {
            List {
                ForEach(stores, id: \.self) { store in
                    Section(header: Text(store).onDrop(of: [kUTTypePlainText as String], delegate: DropViewDelegate(store: store, items: $groceryItems))) {
                        ForEach(groceryItems.filter { $0.store == store }) { item in
                            Text(item.name)
                                .onDrag {
                                    let data = item.id.uuidString.data(using: .utf8)!
                                    let itemProvider = NSItemProvider(item: data as NSSecureCoding, typeIdentifier: kUTTypePlainText as String)
                                    return itemProvider
                                }
                        }
                    }
                }
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
        if !newItemName.isEmpty {
            let newItem = GroceryItem(name: newItemName, store: newStoreName.isEmpty ? "Unspecified" : newStoreName)
            groceryItems.append(newItem)
            newItemName = ""
        }

        if !newStoreName.isEmpty && !stores.contains(newStoreName) {
            stores.append(newStoreName)
            newStoreName = ""
        }
    }
}

struct GroceryItem: Identifiable {
    let id = UUID()
    var name: String
    var store: String
}

struct DropViewDelegate: DropDelegate {
    let store: String
    @Binding var items: [GroceryItem]

    func performDrop(info: DropInfo) -> Bool {
        if let itemProvider = info.itemProviders(for: [kUTTypePlainText as String]).first {
            itemProvider.loadItem(forTypeIdentifier: kUTTypePlainText as String, options: nil) { (item, error) in
                DispatchQueue.main.async {
                    if let itemId = item as? Data, let idString = String(data: itemId, encoding: .utf8), let uuid = UUID(uuidString: idString) {
                        if let index = self.items.firstIndex(where: { $0.id == uuid }) {
                            self.items[index].store = self.store
                        }
                    }
                }
            }
            return true
        } else {
            return false
        }
    }
}
