import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @EnvironmentObject var appDelegate: AppDelegate


    var body: some View {
        Group {
            
            // Skip the login flow if you are not testing it. Signing in doesnt work for simulators.
            #if targetEnvironment(simulator)
            // Skip login logic if running on simulator
            NavigationView {
                ListView()
                    .environment(\.managedObjectContext, viewContext)
                
               
            }
            Spacer()
            Button("Send Message") {
                        appDelegate.sendMessage()
                }
            #else
            if isLoggedIn {
                NavigationView {
                    ListView()
                        .environment(\.managedObjectContext, viewContext)
                }
            } else {
                NavigationView {
                    ICloudLoginView()
                        .frame(minWidth: 200, idealWidth: 300, maxWidth: .infinity, minHeight: 200, idealHeight: 300, maxHeight: .infinity)
                        .navigationTitle("Items")
                        .environment(\.managedObjectContext, viewContext)
                }
            }
            #endif
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ICloudLoginView()
    }
}
