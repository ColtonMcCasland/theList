import SwiftUI
import WatchConnectivity

struct ContentView: View {
    private let connectivityHandler = WatchConnectivityHandler.shared

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            
            List(connectivityHandler.items, id: \.self) { item in
            Text(item)
            }
        }
        .padding()
        .onAppear {
            connectivityHandler.sendDataToiOSApp()
        }
    }
}


extension WatchConnectivityHandler {
    func sendDataToiOSApp() {
        guard WCSession.default.isReachable else {
            // Handle the case when the iOS app is not reachable
            return
        }
        
        let message: [String: Any] = [:] // You can add additional data if needed
        WCSession.default.sendMessage(message, replyHandler: nil) { error in
            // Handle the send message error here
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
