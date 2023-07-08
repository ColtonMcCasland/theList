import SwiftUI
import CloudKit

class DataFetcher: ObservableObject {
    let container: CKContainer
    let database: CKDatabase

    init() {
        container = CKContainer.default()
        database = container.publicCloudDatabase
        fetchData()
    }

    func fetchData() {
        let query = CKQuery(recordType: "Item", predicate: NSPredicate(value: true))

        database.perform(query, inZoneWith: nil) { records, error in
            if let error = error {
                print("Error fetching records: \(error)")
            } else if let records = records {
                for record in records {
                    print("Record: \(record)")
                }
            }
        }
    }
}


@main
struct Kitchen_SyncCompanion_Watch_App: App {
    @StateObject private var dataFetcher = DataFetcher()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataFetcher)
        }
    }
}
