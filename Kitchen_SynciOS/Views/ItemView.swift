import SwiftUI
import UniformTypeIdentifiers

struct ItemView: View {
    var item: GroceryItem
    @State private var isDragOver = false

    var body: some View {
        ZStack {
            if isDragOver {
                // This is the appearance of the cell when a drag operation is over it.
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.5))
            } else {
                // This is the normal appearance of the cell.
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
            }
            Text(item.name ?? "Unnamed")
        }
        .frame(height: 50)
        .onDrag {
            let itemData = ItemData(id: item.id ?? UUID(), name: item.name ?? "", storeName: item.store?.name ?? "")
            let encoder = JSONEncoder()
            if let data = try? encoder.encode(itemData) {
                return NSItemProvider(item: data as NSData, typeIdentifier: UTType.data.identifier)
            } else {
                return NSItemProvider()
            }
        }
        .onDrop(of: [UTType.data.identifier], isTargeted: $isDragOver) { providers, location in
            // You might want to handle the drop here, or you might handle it in the onDrop of the parent view.
            false
        }
    }
}
