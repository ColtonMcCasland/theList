import SwiftUI
import UniformTypeIdentifiers

struct ItemView: View {
    @ObservedObject var item: GroceryItem

    var body: some View {
        Button(action: {
            item.isBought.toggle()
            try? item.managedObjectContext?.save()
        }) {
            Text(item.name ?? "Unspecified")
                .strikethrough(item.isBought)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
