// Kitchen_SynciOSApp.swift

import SwiftUI
import WatchConnectivity

@main
struct theList: App {
    
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	let persistenceController = PersistenceController.shared

		var body: some Scene {
		  WindowGroup {
				ViewController()
				 .environment(\.managedObjectContext, appDelegate.persistenceController.container.viewContext)
				 .environmentObject(appDelegate)
        }
    }
}
