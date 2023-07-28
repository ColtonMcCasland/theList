import SwiftUI

struct StoreView: View {
    let store: Store
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var refresh: Bool
    private let itemDeleter = ItemDeleter()

    var body: some View {
        VStack {
            Text(store.name ?? "Unspecified")
            ForEach(store.itemsArray, id: \.self) { item in
                HStack {
                    Text(item.name ?? "Unspecified")
                    Spacer()
                    Button(action: {
                        if itemDeleter.deleteItem(item: item, from: store, in: viewContext) {
                            refresh.toggle()
                        }
                    }) {
                        Image(systemName: "trash")
                    }
                }
            }
        }
    }
}
