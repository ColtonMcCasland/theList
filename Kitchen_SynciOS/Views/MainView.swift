import SwiftUI

struct MainView: View {
    @State private var groceryItems = [GroceryItem]()
    @State private var newItemName = ""
    @State private var newStoreName = ""
    @State private var showingAddItemView = false
    @State private var showingAddStoreView = false
    @State private var stores = [String]()
    @AppStorage("isLoggedIn") var isLoggedIn = true

    var body: some View {
        if isLoggedIn {
            NavigationView {
                VStack {
                    
                    List {
                        ForEach(groceryItems) { item in
                            CardView(item: item)
                                .onTapGesture {
                                    if let index = groceryItems.firstIndex(where: { $0.id == item.id }) {
                                        groceryItems[index].isDone.toggle()
                                    }
                                }
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Menu {
                            Button(action: {
                                print("User logged out")
                                isLoggedIn = false
                            }) {
                                Label("Log out", systemImage: "arrow.backward.square")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showingAddItemView = true
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                }
                .sheet(isPresented: $showingAddItemView) {
                    AddItemView(newItemName: $newItemName, groceryItems: $groceryItems)
                }
                .sheet(isPresented: $showingAddStoreView) {
                    AddStoreView(newStoreName: $newStoreName, stores: $stores)
                }
            }
            .navigationBarTitle("Grocery List", displayMode: .inline)

        } else {
            ICloudLoginView()
        }
    }
}


struct CardView: View {
    let item: GroceryItem

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(item.name)
                    .font(.headline)
                Text(item.store)
                    .font(.subheadline)
            }
            Spacer()
            Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

struct AddItemView: View {
    @Binding var newItemName: String
    @Binding var groceryItems: [GroceryItem]
    @State private var newStoreName = ""
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                TextField("Item Name", text: $newItemName)
                TextField("Store", text: $newStoreName)
                    .autocapitalization(.words)
                    .disableAutocorrection(false)
            }
            .navigationTitle("Add Item")
            .navigationBarItems(trailing: Button("Save") {
                let newItem = GroceryItem(name: newItemName, store: newStoreName)
                groceryItems.append(newItem)
                newItemName = ""
                newStoreName = ""
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}


struct AddStoreView: View {
    @Binding var newStoreName: String
    @Binding var stores: [String]
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                TextField("Store Name", text: $newStoreName)
            }
            .navigationTitle("Add Store")
            .navigationBarItems(trailing: Button("Save") {
                stores.append(newStoreName)
                newStoreName = ""
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}


struct GroceryItem: Identifiable {
    let id = UUID()
    var name: String
    var store: String
    var isDone = false
}
