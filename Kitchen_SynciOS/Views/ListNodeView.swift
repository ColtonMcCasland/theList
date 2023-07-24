////
////  ListNodeView.swift
////  Kitchen_Sync
////
////  Created by Colton McCasland on 7/24/23.
////
//import SwiftUI
//import CoreData
//
//struct ListNodeView: View {
//    @Environment(\.managedObjectContext) private var viewContext // Access the managedObjectContext
//    var listNode: ListNode
//
//    @State private var showingAddItemView = false
//    @State private var newItemTitle = ""
//
//    // Define fetchRequest as a property of ListNodeView
//    private var fetchRequest: FetchRequest<ListItem>
//
//    init(listNode: ListNode) {
//        self.listNode = listNode
//        self.fetchRequest = FetchRequest<ListItem>(
//            entity: ListItem.entity(),
//            sortDescriptors: [NSSortDescriptor(keyPath: \ListItem.timestamp, ascending: true)],
//            predicate: NSPredicate(format: "listNode == %@", listNode),
//            animation: .default)
//    }
//
//    var body: some View {
//
//        ZStack {
//            Text("ListNodeView")
//
//            List {
//
//                ForEach(fetchRequest.wrappedValue, id: \.self) { item in
//                    HStack {
//                        // Circle that is filled if the item is tapped
//                        Circle()
//                            .fill(item.isTapped ? Color.green : Color.red)
//                            .frame(width: 20, height: 20)
//
//                        VStack(alignment: .leading) {
//                            Text(item.title ?? "No Title") // Use "No Title" if title is nil
//                            Text(item.isTapped ? "Tapped" : "Not Tapped")
//                        }
//                    }
//                    .onTapGesture {
//                        withAnimation {
//                            item.isTapped.toggle()
//                            do {
//                                try viewContext.save()
//                            } catch {
//                                // Handle the error
//                            }
//                        }
//                    }
//                }
//                .onDelete(perform: deleteItems)
//            }
//
//            .toolbar {
//                #if os(iOS)
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    EditButton()
//                }
//                #endif
//
//                ToolbarItem {
//                    Button(action: { showingAddItemView = true }) {
//                        Label("Add Item", systemImage: "plus")
//                    }
//                }
//            }
//
//            if showingAddItemView {
//                AddItemView(isShowing: $showingAddItemView, title: $newItemTitle, addItemAction: addItem)
//                    .transition(.move(edge: .bottom))
//            }
//        }
//    }
//
//    private func addItem() {
//        withAnimation {
//            let newItem = ListItem(context: viewContext)
//            newItem.timestamp = Date()
//            newItem.title = newItemTitle
//            newItem.isTapped = false
//            newItem.listNode = listNode
//
//            do {
//                try viewContext.save()
//                newItemTitle = "" // Reset the title for the next item
//            } catch {
//                // Handle error
//            }
//        }
//    }
//
//    private func deleteItems(offsets: IndexSet) {
//        withAnimation {
//            offsets.map { fetchRequest.wrappedValue[$0] }.forEach(viewContext.delete)
//
//            do {
//                try viewContext.save()
//            } catch {
//                // Handle error
//            }
//        }
//    }
//}
