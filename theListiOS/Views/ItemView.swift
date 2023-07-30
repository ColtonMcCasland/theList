import SwiftUI
import UniformTypeIdentifiers

struct ItemView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var item: GroceryItem

    var body: some View {
        Button(action: {
            item.isBought.toggle()
            do {
                try viewContext.save()
            } catch {
                // handle the Core Data error
            }
            if let store = item.store {
                checkAndDeleteStoreIfAllItemsBought(store: store)
            }
        }) {
            Text(item.name ?? "Unspecified")
                .strikethrough(item.isBought)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func checkAndDeleteStoreIfAllItemsBought(store: Store) {
        let allItemsBought = store.itemsArray.allSatisfy { $0.isBought }
        if allItemsBought {
            viewContext.delete(store)
            do {
                try viewContext.save()
            } catch {
                // handle the Core Data error
            }
        }
    }
}
