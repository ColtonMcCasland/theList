import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newItem = GroceryItem(context: viewContext)
            newItem.timestamp = Date()
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "theList")

        let description = container.persistentStoreDescriptions.first
        description?.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        description?.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)

        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { [self] (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }

            // Fetch items from Core Data
            let fetchRequest: NSFetchRequest<GroceryItem> = GroceryItem.fetchRequest()
            do {
                let items = try container.viewContext.fetch(fetchRequest)
                print("Items in Core Data:")
                for item in items {
                    print(item)
                }
            } catch {
                print("Error fetching items: \(error)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
    }
    
    private func processCloudKitChanges(_ notification: Notification) {
        guard notification.userInfo != nil else { return }
        
        let context = container.viewContext
        context.perform {
            // Refresh the objects in the context
            context.refreshAllObjects()
            
            do {
                try context.save()
            } catch {
                // Handle the error appropriately
                print("Error saving view context: \(error)")
            }
        }
    }

}


