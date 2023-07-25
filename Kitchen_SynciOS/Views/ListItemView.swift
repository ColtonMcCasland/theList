import SwiftUI
import CoreData

struct ListItemView: View {
    @ObservedObject var item: ListItem
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        HStack {
            // Circle that is filled if the item is tapped
            Circle()
                .fill(item.isTapped ? Color.green : Color.red)
                .frame(width: 20, height: 20)
                .onTapGesture {
                    withAnimation {
                        item.isTapped.toggle()
                        do {
                            try viewContext.save()
                            print("Successfully saved context after updating isTapped.")
                        } catch {
                            print("Failed to save context after updating isTapped. Error: \(error)")
                        }
                    }
                }

            Text(item.title ?? "No Title") // Use "No Title" if title is nil
        }
        .padding()
        .contextMenu {
            Button(action: {
                viewContext.delete(item)
                do {
                    try viewContext.save()
                } catch {
                    print("Failed to save context after deleting item. Error: \(error)")
                }
            }) {
                Text("Delete")
                Image(systemName: "trash")
            }
        }
    }
}
