import WatchConnectivity
import CoreData

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

                }
            } catch {
                // Handle error
            }
        }
    }
    
    func fetchAndPrintRecords() {
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()

        do {
            // Fetch the records from the persistent store.
            let records = try PersistenceController.shared.container.viewContext.fetch(fetchRequest)

            print("Fetched \(records.count) records")

            // Print out the records.
            for record in records {
                print(record)
            }
        } catch {
            print("Failed to fetch records: \(error)")
        }
    }
}

struct CustomError: Error {
    let message: String
}
