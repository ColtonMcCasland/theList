import SwiftUI
import WatchConnectivity

struct ContentView: View {
    @EnvironmentObject var modelData: ModelData

    var body: some View {
        ListView(items: modelData.items)
            .onAppear {
                // Perform any necessary actions when the view appears
                // For example, you can trigger the data transfer to the watchOS app here
                sendListDataToWatchOS()
            }
    }

    private func sendListDataToWatchOS() {
        let data: [String: Any] = [
            "listData": modelData.items
        ]
        
        // Access the ConnectivityHandler instance and send the data to the watchOS app
        if let connectivityHandler = WKExtension.shared().delegate as? ExtensionDelegate {
            connectivityHandler.modelData.items = modelData.items
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ModelData())
    }
}
