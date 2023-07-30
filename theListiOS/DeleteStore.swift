import CoreData

func deleteStore(store: Store, in viewContext: NSManagedObjectContext) {
    viewContext.delete(store)
    do {
        try viewContext.save()
    } catch {
        let nserror = error as NSError
        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
    }
}
