//
//  Kitchen_SyncMacOSApp.swift
//  Kitchen_SyncMacOS
//
//  Created by Colton McCasland on 7/4/23.
//

import SwiftUI

@main
struct Kitchen_SyncMacOSApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
