// WatchManager.swift

import WatchConnectivity
import Combine

class WatchManager: NSObject, WCSessionDelegate, ObservableObject {
    @Published var records = [Record]() {
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
        }
    
    private func saveRecords() {
           let encoder = JSONEncoder()
           if let encodedRecords = try? encoder.encode(records) {
               UserDefaults.standard.set(encodedRecords, forKey: "records")
           }
       }

       private func loadRecords() {
           let decoder = JSONDecoder()
           if let savedRecords = UserDefaults.standard.object(forKey: "records") as? Data,
              let decodedRecords = try? decoder.decode([Record].self, from: savedRecords) {
               records = decodedRecords
           }
       }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Handle activation completion if needed
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.global().async { [weak self] in
            self?.updateRecords(from: message)
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
            let message: [String: Any] = ["updateIsTapped": tappedItem.isTapped, "timestamp": tappedItem.timestamp] // Send the current state of isTapped
            WCSession.default.sendMessage(message, replyHandler: nil, errorHandler: { error in
                // Handle error
                print("Error sending message to iOS app: \(error.localizedDescription)")
            })
        }
    }

}

