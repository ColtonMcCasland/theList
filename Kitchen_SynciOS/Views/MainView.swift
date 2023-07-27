import SwiftUI

struct MainView: View {
    @State private var groceryItems = [GroceryItem]()
    @State private var newItemName = ""
    @State private var newStoreName = ""
    @State private var showingAddItemView = false

    var body: some View {
        VStack {
            List {
                ForEach(groceryItems) { item in
                    HStack {
                        Text(item.name)
                        Spacer()
                        Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                            .onTapGesture {
                                if let index = groceryItems.firstIndex(where: { $0.id == item.id }) {
                                    groceryItems[index].isDone.toggle()
                                }
                            }
                    }
                }
            }
            Button(action: {
                showingAddItemView = true
            }) {
                Text("Add Item")
            }
            .sheet(isPresented: $showingAddItemView) {
                AddItemView(newItemName: $newItemName, newStoreName: $newStoreName, groceryItems: $groceryItems)
            }
        }
    }
}

struct AddItemView: View {
    @Binding var newItemName: String
    @Binding var newStoreName: String
    @Binding var groceryItems: [GroceryItem]
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            TextField("Item Name", text: $newItemName)
            TextField("Store Name", text: $newStoreName)
            Button(action: {
                let newItem = GroceryItem(name: newItemName, store: newStoreName)
                groceryItems.append(newItem)
                newItemName = ""
                newStoreName = ""
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Add")
            }
        }
    }
}

struct GroceryItem: Identifiable {
    let id = UUID()
    var name: String
    var store: String
    var isDone = false
}
