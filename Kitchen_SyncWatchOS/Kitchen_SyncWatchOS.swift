import SwiftUI
import WatchConnectivity

@main
struct Kitchen_SyncWatchOS: App {
    @WKExtensionDelegateAdaptor(ExtensionDelegate.self) var extensionDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
