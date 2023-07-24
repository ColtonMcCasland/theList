// ContentView.swift
import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @EnvironmentObject var appDelegate: AppDelegate

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ListNode.timestamp, ascending: true)],
        animation: .default)
    private var listNodes: FetchedResults<ListNode>

    var body: some View {
        NavigationView {
            if isLoggedIn {
                List {
                    ForEach(listNodes) { listNode in
                        NavigationLink(destination: ListView(listNode: listNode)
                                        .environment(\.managedObjectContext, viewContext)) {
                            Text(listNode.title ?? "")
                        }
                    }
                }
                .listStyle(SidebarListStyle())
            } else {
                ICloudLoginView()
                    .frame(minWidth: 200, idealWidth: 300, maxWidth: .infinity, minHeight: 200, idealHeight: 300, maxHeight: .infinity)
                    .navigationTitle("Items")
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }
}
