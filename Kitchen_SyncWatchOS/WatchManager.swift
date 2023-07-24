// WatchManager.swift

import WatchConnectivity
import Combine

class WatchManager: NSObject, WCSessionDelegate, ObservableObject {
    static let shared = WatchManager() // Add this line

    
    
    @Published var records = [NodeItem]() {
           didSet {
               saveRecords()
           }
       }

    override init() {
            super.init()

            if WCSession.isSupported() {
                let session = WCSession.default
                session.delegate = self
                session.activate()
            }

            loadRecords()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // Add this line
                self.requestRecordsFromiOSApp()
            }
        }
    
    
    
    private func saveRecords() {
           let encoder = JSONEncoder()
           if let encodedRecords = try? encoder.encode(records) {
               UserDefaults.standard.set(encodedRecords, forKey: "records")
           }
       }

       private func loadRecords() {
           let decoder = JSONDecoder()
           if let savedRecords = UserDefaults.standard.object(forKey: "node_items") as? Data,
              let decodedRecords = try? decoder.decode([NodeItem].self, from: savedRecords) {
               records = decodedRecords
           }
       }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
            if activationState == .activated {
                requestRecordsFromiOSApp() // Add this line
            }
        }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            if let recordsDict = message["node_items"] as? [[String: Any]] {
                var newRecords = [NodeItem]()
                for dict in recordsDict {
                    if let timestamp = dict["timestamp"] as? Date,
                       let title = dict["title"] as? String,
                       let isTapped = dict["isTapped"] as? Bool {
                        newRecords.append(NodeItem(timestamp: timestamp, title: title, isTapped: isTapped))
                    }
                }
                self.records = newRecords
            }
        }
    }

    
    func requestRecordsFromiOSApp() {
           if WCSession.default.isReachable {
               let message: [String: Any] = ["requestRecords": true]
               WCSession.default.sendMessage(message, replyHandler: nil, errorHandler: { error in
                   // Handle error
                   print("Error requesting records from iOS app: \(error.localizedDescription)")
               })
           }
       }
    
    func sendRecordsToiOSApp() {
           if WCSession.default.isReachable {
               let recordsDict = records.map { ["timestamp": $0.timestamp, "title": $0.title, "isTapped": $0.isTapped] as [String : Any] }
               let message: [String: Any] = ["records": recordsDict]
               WCSession.default.sendMessage(message, replyHandler: nil, errorHandler: { error in
                   // Handle error
                   print("Error sending records to iOS app: \(error.localizedDescription)")
               })
           }
       }
    
    private func updateRecords(from dictionary: [String: Any]) {
        if let recordsDict = dictionary["node_items"] as? [[String: Any]] {
            DispatchQueue.main.async {
                self.records = recordsDict.compactMap { dict in
                    if let timestamp = dict["timestamp"] as? Date,
                       let title = dict["title"] as? String,
                       let isTapped = dict["isTapped"] as? Bool {
                        return NodeItem(timestamp: timestamp, title: title, isTapped: isTapped)
                    }
                    return nil
                }
            }
        }
    }
    
    func toggleIsTapped(for recordIndex: Int) {
        records[recordIndex].isTapped.toggle() // Update the state immediately

        // Send a message to the iOS app to update the corresponding item's isTapped property
        if WCSession.default.isReachable {
            let tappedItem = records[recordIndex]
            let message: [String: Any] = ["updateIsTapped": tappedItem.isTapped, "timestamp": tappedItem.timestamp]
            WCSession.default.sendMessage(message, replyHandler: nil, errorHandler: { error in
                // Handle error
                print("Error sending message to iOS app: \(error.localizedDescription)")
            })
        }
    }

}

