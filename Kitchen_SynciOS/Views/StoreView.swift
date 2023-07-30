import SwiftUI

struct StoreView: View {
    @Environment(\.managedObjectContext) private var viewContext
    let store: Store
    @Binding var isAddItemAndStoreVisible: Bool
    @Binding var selectedStore: Store?

    var body: some View {
        VStack {
            Text(store.name ?? "Unspecified")
                .onTapGesture {
                       print("StoreView: Store \(store.name ?? "Unspecified") was tapped")
                       selectedStore = store
                       isAddItemAndStoreVisible = true
                       print("StoreView: selectedStore set to \(selectedStore?.name ?? "None")")
                       print("StoreView: isAddItemAndStoreVisible set to \(isAddItemAndStoreVisible)")
                   }
            ForEach(store.itemsArray, id: \.self) { item in
                HStack {
                    ItemView(item: item)
                    Spacer()
                }
                .onTapGesture {
                    item.isBought.toggle()
                    do {
                        try viewContext.save()
                    } catch {
                        // handle the Core Data error
                    }
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
