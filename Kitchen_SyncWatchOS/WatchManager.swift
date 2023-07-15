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
    
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        DispatchQueue.main.async {
            self.updateRecords(from: applicationContext)
        }
    }
    
    private func updateRecords(from dictionary: [String: Any]) {
        if let recordsDict = dictionary["records"] as? [[String: Any]] {
            DispatchQueue.main.async {
                self.records = recordsDict.compactMap { dict in
                    if let timestamp = dict["timestamp"] as? Date {
                        return Record(timestamp: timestamp)
                    }
                    return nil
                }
            }
        }
    }
    

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Handle activation completion if needed
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let recordsDict = message["records"] as? [[String: Any]] {
            DispatchQueue.main.async {
                self.records = recordsDict.compactMap { dict in
                    if let timestamp = dict["timestamp"] as? Date {
                        return Record(timestamp: timestamp)
                    }
                    return nil
                }
            }
        }
    }
}
