import CoreData
import SwiftUI

// Helper function to add an item and store to the CoreData context
func addItemAndStore(newItemName: String, newStoreName: String, stores: FetchedResults<Store>, viewContext: NSManagedObjectContext, refresh: Binding<Bool>, selectedStore: Binding<Store?>) {
	let formattedStoreName = newStoreName.trimmingCharacters(in: .whitespacesAndNewlines).capitalized
	let formattedItemName = newItemName.trimmingCharacters(in: .whitespacesAndNewlines).capitalized
	
	let store: Store
	if !formattedStoreName.isEmpty {
		// Check if a store with the given name already exists
		if let existingStore = stores.first(where: { $0.name?.trimmingCharacters(in: .whitespacesAndNewlines).capitalized == formattedStoreName }) {
			// If it does, use that store
			store = existingStore
			// Update the selectedStore
			DispatchQueue.main.async {
				selectedStore.wrappedValue = existingStore
			}
		} else {
			// If not, create a new store
			store = Store(context: viewContext)
			store.name = formattedStoreName
		}
	} else {
		// If no store name was provided, create a new store with a default name
		store = Store(context: viewContext)
		store.name = "Unspecified"
	}
	
	if !formattedItemName.isEmpty {
		let newItem = GroceryItem(context: viewContext)
		newItem.name = formattedItemName
		newItem.store = store
	}
	
	do {
		try viewContext.save()
		viewContext.refreshAllObjects() // Refresh the managed objects to trigger a fetch request update
	} catch {
		let nserror = error as NSError
		fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
	}
}
