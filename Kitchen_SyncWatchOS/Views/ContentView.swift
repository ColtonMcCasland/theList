import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var connectivityHandler: WatchConnectivityHandler

    var body: some View {
        VStack {
            if connectivityHandler.sharedRecords.isEmpty {
                Text("No data retrieved")
                    .font(.headline)
                    .foregroundColor(.gray)
            } else if connectivityHandler.error != nil {
                Text("Error retrieving data")
                    .font(.headline)
                    .foregroundColor(.red)
            } else {
                ListView(records: connectivityHandler.sharedRecords)
            }

            Button(action: {
                // Call sendRecordsToWatch when the button is tapped
                let recordsToSync = [KitchenSyncRecord(id: UUID(), name: "Record 1", date: Date()),
                                     KitchenSyncRecord(id: UUID(), name: "Record 2", date: Date())]
                connectivityHandler.sendRecordsToWatch(recordsToSync)
            }) {
                Text("Sync Data")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(WatchConnectivityHandler())
    }
}
