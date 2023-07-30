import SwiftUI
import CoreData

struct AddItemAndStoreCardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Store.name, ascending: true)],
        animation: .default)
    private var stores: FetchedResults<Store>

    @Binding var newItemName: String
    @Binding var newStoreName: String
    @Binding var isAddItemAndStoreVisible: Bool
    @Binding var selectedStore: Store?
    @Binding var refresh: Bool
    @Binding var isKeyboardShowing: Bool

    @State private var cardHeight: CGFloat = 100
    @State private var dragTranslation: CGFloat = 0
    private let screenHeight = UIScreen.main.bounds.height
    private let maximumCardHeight: CGFloat = 400 // Limit the card height when fully expanded

    var body: some View {
        ZStack(alignment: .top) {
            VStack {
                TextField("New item name", text: $newItemName)
                    .padding(.horizontal, 20) // Reduce horizontal padding
                    .padding(.vertical, 10)   // Reduce vertical padding
                    .font(.headline)          // Adjust font size
                    .opacity(isAddItemAndStoreVisible && cardHeight >= 250 ? 1 : 0)
                if selectedStore == nil {
                    TextField("New store name", text: $newStoreName)
                        .padding(.horizontal, 20) // Reduce horizontal padding
                        .padding(.vertical, 10)   // Reduce vertical padding
                        .font(.headline)          // Adjust font size
                        .opacity(isAddItemAndStoreVisible && cardHeight >= 250 ? 1 : 0)
                }
                Button("Add Item") {
                    addItemAndStore(newItemName: newItemName, newStoreName: selectedStore?.name ?? newStoreName, stores: stores, viewContext: viewContext, refresh: $refresh)
                    newItemName = ""
                    newStoreName = ""
                    isAddItemAndStoreVisible = false
                    selectedStore = nil
                    if isKeyboardShowing {
                        dismissKeyboard()
                    }
                }
                .font(.headline)              // Adjust font size
                .opacity(isAddItemAndStoreVisible && cardHeight >= 250 ? 1 : 0)
                .disabled(newItemName.isEmpty || (newStoreName.isEmpty && selectedStore == nil))
                .padding()
            }
            .frame(maxWidth: .infinity)
            .frame(height: cardHeight) // Use the dynamic card height
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white)
                    .shadow(radius: 5)
            )
            .offset(y: max(30, cardHeight - screenHeight + 100)) // Offset the card down when collapsed, with a buffer of 100 points to prevent exposure of the bottom

            // New Rectangle for the draggable view (Grey bar)
            Rectangle()
                .frame(width: 50, height: 5)
                .foregroundColor(.gray)
                .cornerRadius(2.5)
                .padding(.top, 10)
                .offset(y: max(30, cardHeight - screenHeight + 100)) // Use the same offset as the VStack

        }
        .frame(maxWidth: .infinity) // Expand to full screen width
        .frame(height: cardHeight) // Use the dynamic card height
        .background(Color.clear)   // Set the background color to clear
        .animation(.spring(), value: isAddItemAndStoreVisible)
        .onPreferenceChange(CardHeightKey.self) { cardHeight = $0 }
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragTranslation = value.translation.height
                    cardHeight = max(100, min(cardHeight - value.translation.height, maximumCardHeight))
                }
                .onEnded { value in
                    dragTranslation = 0 // Reset the drag translation
                    let flickVelocity = value.predictedEndTranslation.height // Use the velocity of the flick gesture
                    
                    if flickVelocity < 0 {
                        self.isAddItemAndStoreVisible = true // Fully open the card for an upward flick
                        withAnimation(.spring()) {
                            cardHeight = maximumCardHeight
                        }
                    } else {
                        if cardHeight < maximumCardHeight - 50 {
                            self.isAddItemAndStoreVisible = false // Close the card for a downward flick
                            withAnimation(.spring()) {
                                cardHeight = 100
                            }
                            dismissKeyboard() // Dismiss the system keyboard
                        } else {
                            self.isAddItemAndStoreVisible = true // Keep the card open as the user didn't flick it closed
                            withAnimation(.spring()) {
                                cardHeight = maximumCardHeight
                            }
                        }
                    }
                }
        )

    }

    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    // Define the `addItemAndStore` function here if it's not already defined in your code
    // This function should handle the logic to add items and store to CoreData
    // ...

    // Preference key to track card height
    struct CardHeightKey: PreferenceKey {
        static var defaultValue: CGFloat = 100

        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = nextValue()
        }
    }
}
