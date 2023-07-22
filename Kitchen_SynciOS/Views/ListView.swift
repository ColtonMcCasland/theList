// ListView.swift

import SwiftUI
import CoreData

struct ListView: View {
    @Environment(\.managedObjectContext) private var viewContext // Access the managedObjectContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    @State private var showingAddItemView = false
    @State private var newItemTitle = ""

    var body: some View {
        ZStack {
            List {
                ForEach(items) { item in
                    HStack {
                        // Circle that is filled if the item is tapped
                        Circle()
                            .fill(item.isTapped ? Color.green : Color.red)
                            .frame(width: 20, height: 20)
                        
                        VStack(alignment: .leading) {
                            Text(item.title ?? "No Title") // Use "No Title" if title is nil
                            Text(item.isTapped ? "Tapped" : "Not Tapped")
                        }
                    }
                    .onTapGesture {
                        withAnimation {
                            item.isTapped.toggle()
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                #endif

                ToolbarItem {
                    Button(action: { showingAddItemView = true }) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }

            if showingAddItemView {
                AddItemView(isShowing: $showingAddItemView, title: $newItemTitle, addItemAction: addItem)
                    .transition(.move(edge: .bottom))
                    .animation(.default)
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            newItem.title = newItemTitle
            newItem.isTapped = false

            do {
                try viewContext.save()
                newItemTitle = "" // Reset the title for the next item
            } catch {
                // Handle error
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Handle error
            }
        }
    }
    
}

struct AddItemView: View {
    @Binding var isShowing: Bool
    @Binding var title: String
    let addItemAction: () -> Void

    var body: some View {
        VStack {
            Text("Add a new item")
                .font(.headline)

            TextField("Title", text: $title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                addItemAction()
                isShowing = false
            }) {
                Text("Add Item")
            }
            .padding()
        }
        .frame(width: 300, height: 200)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 20)
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()
