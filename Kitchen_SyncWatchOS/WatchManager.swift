// WatchManager.swift

import WatchConnectivity
import Combine

class WatchManager: NSObject, WCSessionDelegate, ObservableObject {
    @Published var records = [Record]()

    override init() {
        super.init()

        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Handle activation completion if needed
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            self.updateRecords(from: message)
        }
    }
    
    private func updateRecords(from dictionary: [String: Any]) {
        if let recordsDict = dictionary["records"] as? [[String: Any]] {
            DispatchQueue.main.async {
                self.records = recordsDict.compactMap { dict in
                    if let timestamp = dict["timestamp"] as? Date,
                       let title = dict["title"] as? String,
                       let isTapped = dict["isTapped"] as? Bool {
                        return Record(timestamp: timestamp, title: title, isTapped: isTapped)
                    }
                    return nil
                }
            }
        }
    }
    
    func toggleIsTapped(for recordIndex: Int) {
        records[recordIndex].isTapped.toggle()
        
        // Send a message to the iOS app to update the corresponding item's isTapped property
        if WCSession.default.isReachable {
            let tappedItem = records[recordIndex]
            let message: [String: Any] = ["updateIsTapped": true, "timestamp": tappedItem.timestamp]
            WCSession.default.sendMessage(message, replyHandler: nil, errorHandler: { error in
                // Handle error
                print("Error sending message to iOS app: \(error.localizedDescription)")
            })
        }
    }
}
