import SwiftUI
import UniformTypeIdentifiers

struct ItemView: View {
    @ObservedObject var item: GroceryItem

    var body: some View {
        Button(action: {
            item.isTapped.toggle()
            try? item.managedObjectContext?.save()
        }) {
            Text(item.name ?? "Unspecified")
                .strikethrough(item.isTapped)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
