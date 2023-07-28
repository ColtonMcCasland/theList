import CoreData
import SwiftUI

func addItemAndStore(newItemName: String, newStoreName: String, stores: FetchedResults<Store>, viewContext: NSManagedObjectContext, refresh: Binding<Bool>) {
    let formattedStoreName = newStoreName.lowercased().capitalized
    let formattedItemName = newItemName.lowercased().capitalized

    let store: Store
    if !formattedStoreName.isEmpty {
        // Check if a store with the given name already exists
        if let existingStore = stores.first(where: { $0.name?.lowercased().capitalized == formattedStoreName }) {
            // If it does, use that store
            store = existingStore
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
        refresh.wrappedValue.toggle()  // Toggle the refresh state variable to refresh the view
    } catch {
        let nserror = error as NSError
        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
    }
}
