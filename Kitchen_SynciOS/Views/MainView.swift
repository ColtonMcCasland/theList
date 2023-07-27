import SwiftUI

struct MainView: View {
    @State private var groceryItems = [GroceryItem]()
    @State private var newItemName = ""
    @State private var newStoreName = ""
    @State private var showingAddItemView = false
    @State private var showingAddStoreView = false
    @State private var showingFloatingMenu = false
    @AppStorage("isLoggedIn") var isLoggedIn = true

    var body: some View {
        if isLoggedIn { // Add this line
            ZStack {
                NavigationView {
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
                    .navigationBarTitle("Grocery List", displayMode: .inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Menu {
                                Button(action: {
                                    // Add your action for Account Settings here
                                    print("User logged out")
                                    isLoggedIn = false // Add this line
                                }) {
                                    Label("Log out", systemImage: "arrow.backward.square")
                                }
                            } label: {
                                Image(systemName: "ellipsis.circle")
                            }
                        }
                    }
                }
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        FloatingMenu(isOpen: $showingFloatingMenu, addStoreAction: {
                            showingAddStoreView = true
                        }, addItemAction: {
                            showingAddItemView = true
                        })
                    }
                }
                .padding()
                .sheet(isPresented: $showingAddItemView) {
                    AddItemView(newItemName: $newItemName, groceryItems: $groceryItems)
                }
                .sheet(isPresented: $showingAddStoreView) {
                    AddStoreView(newStoreName: $newStoreName)
                }
            }
        } else { // Add this line
            // Add your LoginView here
            ICloudLoginView()
        } // Add this line
    }
}

// ... rest of your code ...


// ... rest of your code ...


struct FloatingMenu: View {
    @Binding var isOpen: Bool
    let addStoreAction: () -> Void
    let addItemAction: () -> Void

    var body: some View {
        VStack {
            if isOpen {
                Button(action: addItemAction) {
                    Image(systemName: "cart.fill")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
                Button(action: addStoreAction) {
                    Image(systemName: "building.fill")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
            }
            Button(action: {
                withAnimation {
                    isOpen.toggle()
                }
            }) {
                Image(systemName: "plus.circle.fill")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Circle())
                    .rotationEffect(.degrees(isOpen ? 45 : 0))
            }
        }
        .transition(.move(edge: .trailing))
    }
}

// ... rest of your code ...


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
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                TextField("Item Name", text: $newItemName)
            }
            .navigationTitle("Add Item")
            .navigationBarItems(trailing: Button("Save") {
                let newItem = GroceryItem(name: newItemName, store: "Default Store")
                groceryItems.append(newItem)
                newItemName = ""
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct AddStoreView: View {
    @Binding var newStoreName: String
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                TextField("Store Name", text: $newStoreName)
            }
            .navigationTitle("Add Store")
            .navigationBarItems(trailing: Button("Save") {
                // Add your action for adding a new store here
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
