import SwiftUI


@main
struct Kitchen_SyncApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
            WindowGroup {
                ContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
