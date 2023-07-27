//
//  AppDelegate.swift
//  Kitchen_Sync
//
//  Created by Colton McCasland on 7/9/23.
//

import Foundation
import SwiftUI
import WatchConnectivity
import CoreData

class AppDelegate: NSObject, UIApplicationDelegate, WCSessionDelegate, ObservableObject {
    let persistenceController = PersistenceController.shared
    
    override init() {
        super.init()

        NotificationCenter.default.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: nil)
    }
    
    @objc private func managedObjectContextObjectsDidChange(_ notification: Notification) {
        DispatchQueue.main.async {
            self.sendRecordsToWatch()
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Set up WatchConnectivity session
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }

        return true
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated {
            sendRecordsToWatch()
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // Check if the message contains the "requestRecords" key
        if let requestRecords = message["requestRecords"] as? Bool, requestRecords {
            sendRecordsToWatch()
        } else {
            // Check if the message contains the "updateIsTapped" key
            if let isTapped = message["updateIsTapped"] as? Bool { // Get the current state of isTapped
                // Check if the message contains the "timestamp" key
                if let timestamp = message["timestamp"] as? Date {
                    // Find the corresponding item in Core Data and update its isTapped property
                    let context = persistenceController.container.newBackgroundContext() // Use a background context
                    context.perform { // Perform operations on the background context
                        let fetchRequest: NSFetchRequest<GroceryItem> = GroceryItem.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "timestamp == %@", timestamp as NSDate)
                        
                        do {
                            let items = try context.fetch(fetchRequest)
                            if let tappedItem = items.first {
                                tappedItem.isTapped = isTapped // Update the isTapped property to the received state
                                try context.save() // Save the changes to Core Data
                            }
                        } catch {
                            // Handle error
                            print("Error updating isTapped property: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }

    
    
    func applicationWillEnterForeground(_ application: UIApplication) {
          sendRecordsToWatch()
      }


    func sessionDidBecomeInactive(_ session: WCSession) {
        // Code to manage an inactive session
    }

    func sessionDidDeactivate(_ session: WCSession) {
        // Code to manage a deactivated session
        WCSession.default.activate()
    }
    
    func sendRecordsToWatch() {
        let context = persistenceController.container.viewContext
        let fetchRequest: NSFetchRequest<GroceryItem> = GroceryItem.fetchRequest()

        do {
            let items = try context.fetch(fetchRequest)
            var records = [[String: Any]]()

            for item in items {
                let record = ["timestamp": item.timestamp as Any, "title": item.name as Any, "isTapped": item.isTapped]
                records.append(record)
            }

            let session = WCSession.default
            if session.activationState == .activated {
                session.sendMessage(["records": records], replyHandler: nil, errorHandler: { error in
                    print("Error sending records to Watch: \(error)")
                })
            }
        } catch {
            print("Error fetching items: \(error)")
        }
    }
}
