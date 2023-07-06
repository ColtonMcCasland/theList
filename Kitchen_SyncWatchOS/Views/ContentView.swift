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


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(WatchConnectivityHandler())
    }
}
