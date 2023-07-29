import SwiftUI

struct StoreView: View {
    @Environment(\.managedObjectContext) private var viewContext
    let store: Store

    var body: some View {
        VStack {
            Text(store.name ?? "Unspecified")
            ForEach(store.itemsArray, id: \.self) { item in
                HStack {
                    ItemView(item: item)
                    Spacer()
                }
                .onTapGesture {
                    item.isBought.toggle()
                    checkAndDeleteStoreIfAllItemsBought(store: store)
                }
            }
        }
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