//
//  Kitchen_SyncApp.swift
//  Kitchen_Sync
//
//  Created by Colton McCasland on 7/1/23.
//

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
