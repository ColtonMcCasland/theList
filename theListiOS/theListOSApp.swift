// Kitchen_SynciOSApp.swift

import SwiftUI
import WatchConnectivity

@main
struct Kitchen_SyncApp: App {
    
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	
		var body: some Scene {
		  WindowGroup {
				ViewController()
				 .environment(\.managedObjectContext, appDelegate.persistenceController.container.viewContext)
				 .environmentObject(appDelegate)
				 .onAppear {
					  appDelegate.sendRecordsToWatch()
				 }
        }
    }
}
