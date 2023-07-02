import WatchConnectivity

class WatchConnectivityHandler: NSObject, WCSessionDelegate {
    static let shared = WatchConnectivityHandler()
    @Published var items: [String] = []

    private override init() {
        super.init()
        
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    // MARK: - WCSessionDelegate
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Handle activation here
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        if let receivedItems = userInfo["items"] as? [String] {
            DispatchQueue.main.async {
                self.items = receivedItems
            }
        }
    }
}
