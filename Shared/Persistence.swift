import CoreData

struct PersistenceController {
	static let shared = PersistenceController()
	
	static var preview: PersistenceController = {
		let result = PersistenceController(inMemory: true)
		let viewContext = result.container.viewContext
		for _ in 0..<10 {
			let newList = List(context: viewContext)
			// Set properties for List as needed
		}
		do {
			try viewContext.save()
		} catch {
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
			
			// Fetch Lists from Core Data
			let fetchRequest: NSFetchRequest<List> = List.fetchRequest()
			do {
				let lists = try container.viewContext.fetch(fetchRequest)
				print("Lists in Core Data:")
				for list in lists {
					print(list)
				}
			} catch {
				print("Error fetching Lists: \(error)")
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
