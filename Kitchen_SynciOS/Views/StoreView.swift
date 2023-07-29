import SwiftUI

struct StoreView: View {
    let store: Store

    var body: some View {
        VStack {
            Text(store.name ?? "Unspecified")
            ForEach(store.itemsArray, id: \.self) { item in
                HStack {
                    ItemView(item: item)
                    Spacer()
                }
            }
        }
    }
}
