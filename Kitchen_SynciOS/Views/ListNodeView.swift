import SwiftUI
import CoreData

struct ListNodeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ListNode.timestamp, ascending: true)],
        animation: .default)
    private var listNodes: FetchedResults<ListNode>
    
    @Binding var showingAddNodeView: Bool


    var body: some View {
        List {
            ForEach(listNodes) { listNode in
                NavigationLink(destination: ListView(listNode: listNode)
                                .environment(\.managedObjectContext, viewContext)) {
                    Text(listNode.title ?? "")
                }
            }
        }
        .listStyle(SidebarListStyle())
        .toolbar {
            ToolbarItem {
                Button(action: { showingAddNodeView = true }) {
                    Label("Add Node", systemImage: "plus")
                }
            }
        }
    }
}
