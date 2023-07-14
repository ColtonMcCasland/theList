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
    
    //...
    @objc private func managedObjectContextObjectsDidChange(_ notification: Notification) {
        DispatchQueue.main.async {
            self.sendRecordsToWatch()
        }
    }
    //...

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
        return true
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Handle activation completion if needed
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // Handle received message
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        // Code to manage an inactive session
    }

    func sessionDidDeactivate(_ session: WCSession) {
        // Code to manage a deactivated session
        WCSession.default.activate()
    }
    
    // function to send records to watch
    //...
    
    
    // for example logic
    func sendMessage() {
        let session = WCSession.default
        if session.activationState == .activated {
            session.sendMessage(["message": "Hello, Apple Watch!"], replyHandler: nil, errorHandler: nil)
        }
    }
    
    func sendRecordsToWatch() {
            let context = persistenceController.container.viewContext
            let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()

            do {
                let items = try context.fetch(fetchRequest)
                var records = [[String: Any]]()

                for item in items {
                    let record = ["timestamp": item.timestamp as Any]
                    records.append(record)
                }

                let session = WCSession.default
                if session.activationState == .activated {
                    session.sendMessage(["records": records], replyHandler: nil, errorHandler: nil)
                }
            } catch {
                print("Error fetching items: \(error)")
            }
        }
}
