import SwiftUI
import CoreData
import UniformTypeIdentifiers

struct ListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Store.name, ascending: true)],animation: .default)
    private var stores: FetchedResults<Store>
	
	// Fetch request for the items with 'Required' priority
	@FetchRequest(entity: GroceryItem.entity(), sortDescriptors: [], predicate: NSPredicate(format: "priority == %@", "Required")) var requiredItems: FetchedResults<GroceryItem>

    @AppStorage("isLoggedIn") private var isLoggedIn = true
    @State private var showingActionSheet = false

    @State private var newItemName = ""
    @State private var newStoreName = ""
	 @State private var newItemPriority = "Optional"

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
					let sortedStores = stores.sorted { store1, store2 in
						let requiredItemsCount1 = store1.itemsArray.filter { $0.priority == "Required" }.count
						let requiredItemsCount2 = store2.itemsArray.filter { $0.priority == "Required" }.count
						return requiredItemsCount1 > requiredItemsCount2
					}
					
                List {
                    ForEach(sortedStores, id: \.self) { store in
                        StoreView(store: store, isAddItemAndStoreVisible: $isAddItemAndStoreVisible, selectedStore: $selectedStore)
                    }
                }
                .listStyle(DefaultListStyle()) // Set the list style to PlainListStyle
					
            }

            Spacer() // Add spacer to push the ZStack to the bottom
			  AddItemAndStoreView(newStoreName: $newStoreName, newItemName: $newItemName, newItemPriority: $newItemPriority, isAddItemAndStoreVisible: $isAddItemAndStoreVisible, selectedStore: $selectedStore, refresh: $refresh, isKeyboardShowing: $isKeyboardShowing)
        }
        .id(refresh)
        .navigationBarTitle("theList.", displayMode: .inline)
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
