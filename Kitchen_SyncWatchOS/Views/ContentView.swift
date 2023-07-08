import SwiftUI

struct ContentView: View {
    @EnvironmentObject var connectivityHandler: WatchConnectivityHandler

    var body: some View {
        Button("Fetch and Print Records") {
            connectivityHandler.fetchAndPrintRecords()
        }
        // Other view code...
    }
}

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



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(WatchConnectivityHandler())
    }
}

