// DeleteItem.swift

import CoreData

struct ItemDeleter {
    func deleteItem(item: GroceryItem, from store: Store, in viewContext: NSManagedObjectContext) -> Bool {
        viewContext.delete(item)
        do {
            try viewContext.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }

        // Check if the store has any items left
        if store.itemsArray.isEmpty {
            // If not, delete the store
            viewContext.delete(store)
            do {
                try viewContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
        
        return true
    }
}
