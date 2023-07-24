// WatchManager.swift

import WatchConnectivity
import Combine

class WatchManager: NSObject, WCSessionDelegate, ObservableObject {
    static let shared = WatchManager() // Add this line

    
    
    @Published var node_items = [NodeItem]() {
           didSet {
               saveNodeItems()
           }
       }

    override init() {
            super.init()

            if WCSession.isSupported() {
                let session = WCSession.default
                session.delegate = self
                session.activate()
            }

            loadNodeItems()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // Add this line
                self.requestNodeItemsFromiOSApp()
            }
        }
    
    
    
    private func saveNodeItems() {
           let encoder = JSONEncoder()
           if let encodedRecords = try? encoder.encode(node_items) {
               UserDefaults.standard.set(encodedRecords, forKey: "records")
           }
       }

       private func loadNodeItems() {
           let decoder = JSONDecoder()
           if let savedRecords = UserDefaults.standard.object(forKey: "records") as? Data,
              let decodedRecords = try? decoder.decode([NodeItem].self, from: savedRecords) {
               node_items = decodedRecords
           }
       }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
            if activationState == .activated {
                requestNodeItemsFromiOSApp() // Add this line
            }
        }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            if let recordsDict = message["records"] as? [[String: Any]] {
                var newRecords = [NodeItem]()
                for dict in recordsDict {
                    if let timestamp = dict["timestamp"] as? Date,
                       let title = dict["title"] as? String,
                       let isTapped = dict["isTapped"] as? Bool {
                        newRecords.append(NodeItem(timestamp: timestamp, title: title, isTapped: isTapped))
                    }
                }
                self.node_items = newRecords
            }
        }
    }

    
    func requestNodeItemsFromiOSApp() {
           if WCSession.default.isReachable {
               let message: [String: Any] = ["requestRecords": true]
               WCSession.default.sendMessage(message, replyHandler: nil, errorHandler: { error in
                   // Handle error
                   print("Error requesting records from iOS app: \(error.localizedDescription)")
               })
           }
       }
    
    func sendNodeItemsToiOSApp() {
           if WCSession.default.isReachable {
               let recordsDict = node_items.map { ["timestamp": $0.timestamp, "title": $0.title, "isTapped": $0.isTapped] }
               let message: [String: Any] = ["records": recordsDict]
               WCSession.default.sendMessage(message, replyHandler: nil, errorHandler: { error in
                   // Handle error
                   print("Error sending records to iOS app: \(error.localizedDescription)")
               })
           }
       }
    
    private func updateNodeItems(from dictionary: [String: Any]) {
        if let recordsDict = dictionary["NodeItems"] as? [[String: Any]] {
            DispatchQueue.main.async {
                self.node_items = recordsDict.compactMap { dict in
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
        node_items[recordIndex].isTapped.toggle() // Update the state immediately

        // Send a message to the iOS app to update the corresponding item's isTapped property
        if WCSession.default.isReachable {
            let tappedItem = node_items[recordIndex]
            let message: [String: Any] = ["updateIsTapped": tappedItem.isTapped, "timestamp": tappedItem.timestamp]
            WCSession.default.sendMessage(message, replyHandler: nil, errorHandler: { error in
                // Handle error
                print("Error sending message to iOS app: \(error.localizedDescription)")
            })
        }
    }

}

