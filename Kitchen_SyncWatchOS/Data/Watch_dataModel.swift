import CloudKit
import Foundation

class ModelData: ObservableObject {
    @Published var items: [watchItem] = []

    init() {
        fetchItemsFromCloudKit()
    }

    private func fetchItemsFromCloudKit() {
        // Implement your CloudKit fetch logic here
        // Fetch the items from the CloudKit container and update the `items` array

        // Example code to fetch items from a CloudKit record zone
        let recordZoneID = CKRecordZone.ID(zoneName: "YourRecordZoneName", ownerName: CKCurrentUserDefaultName)
        let query = CKQuery(recordType: "YourRecordType", predicate: NSPredicate(value: true))
        let operation = CKQueryOperation(query: query)
        operation.zoneID = recordZoneID

        operation.recordFetchedBlock = { record in
            // Process the fetched record and create watchItem objects
            if let name = record["name"] as? String, let description = record["description"] as? String {
                let item = watchItem(name: name, description: description)
                self.items.append(item)
            }
        }

        operation.queryCompletionBlock = { cursor, error in
            // Handle the completion of the query
            if let error = error {
                print("Error fetching items from CloudKit: \(error.localizedDescription)")
            }
        }

        CKContainer.default().publicCloudDatabase.add(operation)
    }
}

struct watchItem: Identifiable {
    let id: UUID
    var name: String
    var description: String

    init(id: UUID = UUID(), name: String, description: String) {
        self.id = id
        self.name = name
        self.description = description
    }
}
