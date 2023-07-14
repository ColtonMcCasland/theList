import SwiftUI
import WatchConnectivity

@main
struct Kitchen_SyncWatchOS: App {
    @StateObject var watchManager = WatchManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(watchManager)
        }
    }
}
