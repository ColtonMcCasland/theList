
import SwiftUI
import WatchConnectivity

@main
struct Kitchen_SyncCompanion_Watch_App: App {
    @StateObject private var connectivityHandler = WatchConnectivityHandler.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(WatchConnectivityHandler.shared)
        }
    }
}
