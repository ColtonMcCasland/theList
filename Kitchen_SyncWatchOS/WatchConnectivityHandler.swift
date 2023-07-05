import WatchConnectivity

class WatchConnectivityHandler: NSObject, WCSessionDelegate, ObservableObject {
    static let shared = WatchConnectivityHandler()

    @Published var sharedRecords: [KitchenSyncRecord] = []
    @Published var localRecords: [KitchenSyncRecord] = []
    @Published var error: CustomError? = nil

    private let session: WCSession? = WCSession.isSupported() ? WCSession.default : nil

    override init() {
        super.init()

        session?.delegate = self
        session?.activate()
    }

    // MARK: - WCSessionDelegate

    // For connection
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Activation state: \(activationState.rawValue == 2 ? "Connected" : "Not Connected")")
        if let error = error {
            print("Activation error: \(error.localizedDescription)")
        }
    }

    /// For receiving records
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        // ...

        if let data = userInfo["sharedRecords"] as? Data {
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let receivedRecords = try decoder.decode([KitchenSyncRecord].self, from: data)
                DispatchQueue.main.async {
                    self.sharedRecords = receivedRecords
                    self.error = nil

                    // Save received records locally
                    self.saveRecordsLocally(receivedRecords)
                }
            } catch {
                // Handle error
            }
        }
    }

    private func saveRecordsLocally(_ records: [KitchenSyncRecord]) {
        // Save records locally (e.g., in UserDefaults or a simple file)
        // ...
    }
    
    // For sending records to watch
    func sendRecordsToWatch(_ records: [KitchenSyncRecord]) {
        guard let session = session, session.isReachable else {
            print("Watch is not reachable")
            return
        }

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        do {
            let sharedRecordsData = try encoder.encode(records)

            session.transferUserInfo(["sharedRecords": sharedRecordsData])
            print("Sent records to watch")

        } catch {
            print("Error encoding records: \(error.localizedDescription)")
            // Handle error
        }
    }
}

struct CustomError: Error {
    let message: String
}
