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
    
    @State private var refresh = false


    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(stores, id: \.self) { store in
                        StoreView(store: store, refresh: $refresh)
                    }
                }
                VStack {
                      TextField("New item name", text: $newItemName)
                      TextField("New store name", text: $newStoreName)
                      Button("Add Item and Store") {
                          addItemAndStore(newItemName: newItemName, newStoreName: newStoreName, stores: stores, viewContext: viewContext)
                          newItemName = ""
                          newStoreName = ""
                      }.disabled(newItemName.isEmpty && newStoreName.isEmpty) // Disable the button when both fields are empty
                }
                .padding()
            }
            .id(refresh)  // Here

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
}
