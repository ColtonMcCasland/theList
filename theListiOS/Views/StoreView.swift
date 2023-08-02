import SwiftUI
import CoreData

struct StoreView: View {
	@Environment(\.managedObjectContext) private var viewContext
	
	let store: Store
	@Binding var isAddItemAndStoreVisible: Bool
	@Binding var selectedStore: Store?
	
	// Fetch request for the items in the store
	@FetchRequest var items: FetchedResults<GroceryItem>
	
	init(store: Store, isAddItemAndStoreVisible: Binding<Bool>, selectedStore: Binding<Store?>) {
		self.store = store
		self._isAddItemAndStoreVisible = isAddItemAndStoreVisible
		self._selectedStore = selectedStore
		
		// Initialize the fetch request
		self._items = FetchRequest(
			entity: GroceryItem.entity(),
			sortDescriptors: [],  // replace with your desired sort descriptors
			predicate: NSPredicate(format: "store == %@", store),
			animation: .default
		)
	}
	
	var body: some View {
		VStack {
			Text(store.name ?? "").font(.title)
				.onTapGesture {
					selectedStore = store
					isAddItemAndStoreVisible = true
				}
			Spacer()
			
			let sortedItems = ItemView.sortRequiredItemsFirst(items)
			ForEach(sortedItems, id: \.self) { item in
				ItemView(item: item)
					.onTapGesture {
						item.isBought.toggle()
						do {
							try viewContext.save()
						} catch {
							// handle the Core Data error
						}
						checkAndDeleteStoreIfAllItemsBought(store: store)
					}
			}
			Spacer()
		}
	}
	
	private func checkAndDeleteStoreIfAllItemsBought(store: Store) {
		let allItemsBought = items.allSatisfy { $0.isBought }
		if allItemsBought {
			viewContext.delete(store)
			do {
				try viewContext.save()
			} catch {
				// handle the Core Data error
			}
		}
	}
}
