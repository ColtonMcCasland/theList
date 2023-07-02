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


class ConnectivityHandler: NSObject, ObservableObject {
    override init() {
        super.init()
        
        if WCSession.isSupported() {
            let session = WCSession.default
            session.activate()
        }
    }
    
    // Add methods to send data to the watchOS app here
}
