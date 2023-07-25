import SwiftUI
import CoreData

struct ListItemView: View {
    @ObservedObject var item: ListItem
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        HStack {
            // Circle that is filled if the item is tapped
            Circle()
                .fill(item.isTapped ? Color.green : Color.red)
                .frame(width: 20, height: 20)
                .onTapGesture {
                    withAnimation {
                        item.isTapped.toggle()
                        do {
                            try viewContext.save()
                            print("Successfully saved context after updating isTapped.")
                        } catch {
                            print("Failed to save context after updating isTapped. Error: \(error)")
                        }
                    }
                }

            Text(item.title ?? "No Title") // Use "No Title" if title is nil
        }
        .padding()
    }
}

struct ListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ListNode.timestamp, ascending: true)],
        animation: .default)
    private var listNodes: FetchedResults<ListNode>
    
    @State private var showingAddNodeModal = false
    @State private var newNodeTitle = ""

    var body: some View {
        ZStack {
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(listNodes) { listNode in
                        VStack {
                            Text(listNode.title ?? "")
                                .font(.headline)
                                .padding()
                            Divider()
                            ForEach(Array(listNode.items as? Set<ListItem> ?? []), id: \.self) { item in
                                        ListItemView(item: item)
                                    }
                            .onDelete(perform: deleteItems)
                        }
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding()
                    }
                }
            }
            .toolbar {
                ToolbarItem {
                    Button(action: { showingAddNodeModal = true }) {
                        Label("Add Node", systemImage: "plus")
                    }
                }
            }

            // The AddNodeView modal
            if showingAddNodeModal {
                AddNodeView(isShowing: $showingAddNodeModal, newNodeTitle: $newNodeTitle, addNodeAction: addNode)
                    .transition(.move(edge: .bottom))
                    .zIndex(1)  // Make sure the modal is above the main content
            }
        }
    }
    
    private func addNode() {
        withAnimation {
            let newNode = ListNode(context: viewContext)
            newNode.timestamp = Date()
            newNode.title = newNodeTitle

            do {
                try viewContext.save()
                newNodeTitle = "" // Reset the title for the next node
            } catch {
                // Handle the error
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { Array(listNodes[$0].items as? Set<ListItem> ?? Set<ListItem>())[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Handle error
            }
        }
    }
}
