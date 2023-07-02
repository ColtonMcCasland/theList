import SwiftUI
import CoreData

struct ListView: View {
    @Environment(\.managedObjectContext) private var viewContext // Access the managedObjectContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    
    private var items: FetchedResults<Item>

    var body: some View {
        List {
            ForEach(items) { item in
                NavigationLink(
                    destination: Text("Item at \(item.timestamp!, formatter: itemFormatter)"),
                    label: {
                        Text(item.timestamp!, formatter: itemFormatter)
                    }
                )
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
                Button(action: addItem) {
                    Label("Add Item", systemImage: "plus")
                }
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
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

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()


struct List_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let item1 = Item(context: context)
        item1.timestamp = Date()
        
        let item2 = Item(context: context)
        item2.timestamp = Date().addingTimeInterval(60)
        
        return ListView()
            .environment(\.managedObjectContext, context)
            .previewLayout(.fixed(width: 375, height: 400)) // Set a desired preview size
            .environment(\.colorScheme, .light) // Specify light or dark mode
    }
}
