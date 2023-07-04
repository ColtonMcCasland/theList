import SwiftUI
import WatchConnectivity


@main
struct Kitchen_SyncCompanion_Watch_AppApp: App {
    @StateObject var modelData = ModelData()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(modelData)
        }
    }
}


class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate {
    @ObservedObject var modelData = ModelData()

    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Handle activation of session
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // Handle received message
        // Update your data model here based on the received message
        if let listData = message["listData"] as? [watchItem] {
            modelData.items = listData
        }
    }
}

