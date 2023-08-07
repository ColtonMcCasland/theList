import CoreData
import SwiftUI

// Helper function to add an item and store to the CoreData context
func addItemAndStore(newItemName: String, newStoreName: String, newItemPriority: String, stores: FetchedResults<Store>, viewContext: NSManagedObjectContext, refresh: Binding<Bool>, selectedStore: Binding<Store?>) -> Bool {
	let formattedStoreName = newStoreName.trimmingCharacters(in: .whitespacesAndNewlines).capitalized
	let formattedItemName = newItemName.trimmingCharacters(in: .whitespacesAndNewlines).capitalized
	let formattedItemPriority = newItemPriority.trimmingCharacters(in: .whitespacesAndNewlines).capitalized
	
	var wasNewStoreAdded = false
	let store: Store
	if !formattedStoreName.isEmpty {
		if let existingStore = stores.first(where: { $0.name?.trimmingCharacters(in: .whitespacesAndNewlines).capitalized == formattedStoreName }) {
			store = existingStore
		} else {
			store = Store(context: viewContext)
			store.name = formattedStoreName
			wasNewStoreAdded = true
		}
	} else {
		store = Store(context: viewContext)
		store.name = "Unspecified"
	}
	
	if !formattedItemName.isEmpty {
		let newItem = GroceryItem(context: viewContext)
		newItem.name = formattedItemName
		newItem.priority = formattedItemPriority
		newItem.store = store
	}
	
	do {
		try viewContext.save()
		viewContext.refreshAllObjects()
	} catch {
		let nserror = error as NSError
		fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
	}
	
	return wasNewStoreAdded
}
