//
//  Kitchen_SyncApp.swift
//  Kitchen_Sync
//
//  Created by Colton McCasland on 7/1/23.
//

import SwiftUI
import WatchConnectivity


@main
struct Kitchen_SyncApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var connectivityHandler = ConnectivityHandler()
    
    var body: some Scene {
            WindowGroup {
                ContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(connectivityHandler)
            }
        }
}


class ConnectivityHandler: ObservableObject {
    private let sessionDelegate = SessionDelegate()

    init() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = sessionDelegate
            session.activate()
        }
    }

    func sendToWatchOS(data: [String: Any]) {
        if WCSession.default.isReachable {
            do {
                try WCSession.default.updateApplicationContext(data)
            } catch {
                print("Failed to send data to watchOS: \(error)")
            }
        } else {
            print("WatchOS app is not reachable")
        }
    }
}

class SessionDelegate: NSObject, WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Handle session activation completion
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        // Handle received application context from watchOS app
    }

    // Add other required WCSessionDelegate methods
    func sessionDidBecomeInactive(_ session: WCSession) {
        // Handle session becoming inactive
    }

    func sessionDidDeactivate(_ session: WCSession) {
        // Handle session deactivation
    }

    func sessionWatchStateDidChange(_ session: WCSession) {
        // Handle watch state change
    }
}
