import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage("isLoggedIn") private var isLoggedIn = false

    var body: some View {
        Group {
            #if targetEnvironment(simulator)
            // Skip login logic if running on simulator
            NavigationView {
                ListView()
                    .environment(\.managedObjectContext, viewContext)
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
