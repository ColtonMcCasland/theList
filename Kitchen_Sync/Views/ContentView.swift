import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage("isLoggedIn") private var isLoggedIn = false

    var body: some View {
            Group {
                if isLoggedIn {
                    ListView()
                        .environment(\.managedObjectContext, viewContext)
                } else {
                    NavigationView {
                        ICloudLoginView()
                            .frame(minWidth: 200, idealWidth: 300, maxWidth: .infinity, minHeight: 200, idealHeight: 300, maxHeight: .infinity)
                            .navigationTitle("Items")
                            .environment(\.managedObjectContext, viewContext)
                }
            }
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}
