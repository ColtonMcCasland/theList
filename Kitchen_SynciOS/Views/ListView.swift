import SwiftUI
import CoreData

struct ListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ListNode.timestamp, ascending: true)],
        animation: .default)
    private var listNodes: FetchedResults<ListNode>
    
    @State private var showingAddNodeModal = false
    @State private var newNodeTitle = ""
    @State private var showingEditNodePopover = false
    @State private var showingAddItemPopover = false
    @State private var nodeToEdit: ListNode? = nil
    @State private var nodeToAddItem: ListNode? = nil
    @State private var editedNodeTitle = ""
    @State private var newItemTitle = ""

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEach(listNodes) { listNode in
                    VStack {
                        HStack {
                            Text(listNode.title ?? "")
                                .font(.headline)
                                .padding()
                            Spacer()
                            Button(action: {
                                nodeToAddItem = listNode
                                showingAddItemPopover = true
                            }) {
                                Image(systemName: "plus")
                            }
                            .popover(isPresented: $showingAddItemPopover) {
                                Form {
                                    TextField("Item Title", text: $newItemTitle)
                                    Button("Add Item") {
                                        addItem(to: nodeToAddItem)
                                        showingAddItemPopover = false
                                    }
                                }
                                .padding()
                            }
                        }
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
                    .contextMenu {
                        Button(action: {
                            nodeToEdit = listNode
                            editedNodeTitle = listNode.title ?? ""
                            showingEditNodePopover = true
                        }) {
                            Text("Edit Node Title")
                            Image(systemName: "pencil")
                        }
                        Button(action: {
                            deleteNode(listNode)
                        }) {
                            Text("Delete Node")
                            Image(systemName: "trash")
                        }
                    }
                    .popover(isPresented: $showingEditNodePopover) {
                        Form {
                            TextField("Node Title", text: $editedNodeTitle)
                            Button("Save") {
                                if let nodeToEdit = nodeToEdit {
                                    nodeToEdit.title = editedNodeTitle
                                    do {
                                        try viewContext.save()
                                    } catch {
                                        // Handle the error
                                    }
                                }
                                showingEditNodePopover = false
                            }
                        }
                        .padding()
                    }
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
    
    private func addItem(to node: ListNode?) {
        withAnimation {
            if let node = node {
                let newItem = ListItem(context: viewContext)
                newItem.title = newItemTitle
                newItem.isTapped = false
                newItem.listNode = node

                do {
                    try viewContext.save()
                    newItemTitle = "" // Reset the title for the next item
                } catch {
                    // Handle the error
                }
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
    
    private func deleteNode(_ node: ListNode) {
        withAnimation {
            // Delete all items associated with the node
            let items = Array(node.items as? Set<ListItem> ?? [])
            items.forEach(viewContext.delete)
            
            // Delete the node itself
            viewContext.delete(node)

            do {
                try viewContext.save()
            } catch {
                // Handle error
            }
        }
    }
}
