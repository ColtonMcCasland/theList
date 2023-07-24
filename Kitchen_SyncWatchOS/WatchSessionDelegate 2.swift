// WatchSessionDelegate.swift

import WatchConnectivity
import Combine

class WatchSessionDelegate: NSObject, WCSessionDelegate, ObservableObject {
    @Published var records = [Record]()

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Handle activation completion if needed
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let recordsDict = message["records"] as? [[String: Any]] {
            self.records = recordsDict.compactMap { dict in
                if let timestamp = dict["timestamp"] as? Date,
                   let title = dict["title"] as? String,
                   let isTapped = dict["isTapped"] as? Bool { // Extract order from dictionary
                    return Record(timestamp: timestamp, title: title, isTapped: isTapped) // Provide order as argument
                }
                return nil
            }
        }
    }
}
