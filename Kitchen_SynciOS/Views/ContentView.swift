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

    @State private var showingAddNodeView = false
    @State private var newNodeTitle = ""

    var body: some View {
        NavigationView {
            if isLoggedIn {
                MainView()
            } else {
                ICloudLoginView()
                    .frame(minWidth: 200, idealWidth: 300, maxWidth: .infinity, minHeight: 200, idealHeight: 300, maxHeight: .infinity)
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }
}
