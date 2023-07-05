import SwiftUI

struct ListView: View {
    var records: [KitchenSyncRecord]

    var body: some View {
        List(records) { record in
            RecordRow(record: record)
        }
    }
}

struct RecordRow: View {
    var record: KitchenSyncRecord

    var body: some View {
        VStack(alignment: .leading) {
            Text(record.name)
        }
    }
}
