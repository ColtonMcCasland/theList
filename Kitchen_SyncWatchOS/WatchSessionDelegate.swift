// WatchSessionDelegate.swift

import WatchConnectivity
import Combine

class WatchSessionDelegate: NSObject, WCSessionDelegate, ObservableObject {
    @Published var records = [[String: Any]]()

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Handle activation completion if needed
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let records = message["records"] as? [[String: Any]] {
            self.records = records
        }
    }
}
