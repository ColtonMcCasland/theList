import SwiftUI
import CoreData
import UniformTypeIdentifiers

struct ListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Store.name, ascending: true)],animation: .default)
    private var stores: FetchedResults<Store>
    @AppStorage("isLoggedIn") private var isLoggedIn = true
    @State private var showingActionSheet = false

    @State private var newItemName = ""
    @State private var newStoreName = ""
    @State private var refresh = false
    @State private var isAddItemAndStoreVisible = false
    @State private var selectedStore: Store?
    @State private var isKeyboardShowing = false
    @State private var slideOffset: CGFloat = 0.0
    @State private var dragOffset: CGFloat = 0.0

    var body: some View {
        VStack {
            if stores.isEmpty || stores.contains(where: { ($0.items as? Set<GroceryItem>)?.isEmpty ?? true }) {
                VStack {
                    Text("The list is empty. Add stores and items.")
                        .padding()
                }
            } else {
                List {
                    ForEach(stores, id: \.self) { store in
                        StoreView(store: store, isAddItemAndStoreVisible: $isAddItemAndStoreVisible, selectedStore: $selectedStore)
                    }
                }
                .listStyle(DefaultListStyle()) // Set the list style to PlainListStyle
            }

            Spacer() // Add spacer to push the ZStack to the bottom
            AddItemAndStoreView(newItemName: $newItemName, newStoreName: $newStoreName, isAddItemAndStoreVisible: $isAddItemAndStoreVisible, selectedStore: $selectedStore, refresh: $refresh, isKeyboardShowing: $isKeyboardShowing)
        }
        .id(refresh)
        .navigationBarTitle("the List.", displayMode: .inline)
        .navigationBarItems(trailing:
            Button(action: {
                showingActionSheet = true
            }) {
                Image(systemName: "ellipsis.circle")
                    .resizable()
                    .frame(width: 24, height: 24)
            }
            .actionSheet(isPresented: $showingActionSheet) {
                ActionSheet(title: Text("Settings"), buttons: [
                    .default(Text("Log Out"), action: {
                        isLoggedIn = false
                        showingActionSheet = false
                    }),
                    .cancel()
                ])
            }
        )
		  .background( Color(.systemGroupedBackground))

    }
}
