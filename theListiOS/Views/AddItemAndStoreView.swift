import SwiftUI
import CoreData

struct AddItemAndStoreView: View {
	@Environment(\.colorScheme) var colorScheme

	@Environment(\.managedObjectContext) private var viewContext
	@FetchRequest(
		sortDescriptors: [NSSortDescriptor(keyPath: \Store.name, ascending: true)],
		animation: .default)
	private var stores: FetchedResults<Store>
	
	@Binding var newStoreName: String
	@Binding var newItemName: String
	@Binding var newItemPriority: String
	let priorities = ["Optional", "Required"]


	@Binding var isAddItemAndStoreVisible: Bool
	@Binding var selectedStore: Store?
	@Binding var refresh: Bool
	@Binding var isKeyboardShowing: Bool
	
	@State private var cardHeight: CGFloat = 100
	@State private var dragTranslation: CGFloat = 0
	private let screenHeight = UIScreen.main.bounds.height
	private let maximumCardHeight: CGFloat = 250
	
    var body: some View {
        ZStack(alignment: .top) {
            VStack {
					
						if selectedStore == nil {
								HStack {
									Image(systemName: "cart")
									TextField("New store name", text: $newStoreName)
								}
								.padding(.horizontal, 20) // Reduce horizontal padding
								.padding(.vertical, 10)   // Reduce vertical padding
								.font(.headline)          // Adjust font size
								.opacity(isAddItemAndStoreVisible && cardHeight >= 250 ? 1 : 0)
								.animation(.spring(), value: cardHeight) // Add animation modifier
							}
						HStack {
							Image(systemName: "checkmark.circle")
							TextField("New item name", text: $newItemName)
						}
					  .padding(.horizontal, 20) // Reduce horizontal padding
					  .padding(.vertical, 10)   // Reduce vertical padding
					  .font(.headline)          // Adjust font size
					  .opacity(isAddItemAndStoreVisible && cardHeight >= 250 ? 1 : 0)
					  .animation(.spring(), value: cardHeight) // Add animation modifier
					
						HStack {
							Image(systemName: "clock.badge.questionmark")
							Picker("Priority", selection: $newItemPriority) {
								ForEach(priorities, id: \.self) {
									Text($0)
								}
							}
							.pickerStyle(SegmentedPickerStyle())
							.font(.headline)          // Adjust font size
						}
						.padding(.horizontal, 20) // Reduce horizontal padding
						.padding(.vertical, 10)   // Reduce vertical padding
						.font(.headline)          // Adjust font size
						.opacity(isAddItemAndStoreVisible && cardHeight >= 250 ? 1 : 0)
						.animation(.spring(), value: cardHeight) // Add animation modifier

					Button("Add Item") {
						addItemAndStore(newItemName: newItemName, newStoreName: selectedStore?.name ?? newStoreName, newItemPriority: newItemPriority, stores: stores, viewContext: viewContext, refresh: $refresh, selectedStore: $selectedStore)
						newItemName = ""
						newStoreName = ""
						selectedStore = nil
					}

					.font(.headline)
					.opacity(isAddItemAndStoreVisible && cardHeight >= 250 ? 1 : 0)
					.disabled(newItemName.isEmpty || (newStoreName.isEmpty && selectedStore == nil))
					.padding()
					.animation(.spring(), value: cardHeight)
            }
            .frame(maxWidth: .infinity)
            .frame(height: cardHeight) // Use the dynamic card height
				.padding()
            
			  
				.background(
					RoundedRectangle(cornerRadius: 16)
						.fill(colorScheme == .dark ? Color(.darkGray) : Color(.white)) // Use dynamic background color based on the mode
						.overlay(
							RoundedRectangle(cornerRadius: 16)
								.stroke(colorScheme == .dark ? Color(.darkGray) : Color(.lightGray), lineWidth: 3) // Customize the border color based on the mode
						)
				)
			  
			  
            .cornerRadius(16) // Apply corner radius directly here
            .offset(y: max(30, cardHeight - screenHeight + 100)) // Offset the card down when collapsed, with a buffer of 100 points to prevent exposure of the bottom
            .onChange(of: isAddItemAndStoreVisible) { newValue in
                withAnimation {
                    cardHeight = newValue ? maximumCardHeight : 100
                }
            }
				.background( Color(.systemGroupedBackground))

            // New Rectangle for the draggable view (Grey bar)
            Rectangle()
                .frame(width: 50, height: 5)
                .cornerRadius(2.5)
                .padding(.top, 10)
                .offset(y: max(30, cardHeight - screenHeight + 100)) // Use the same offset as the VStack
        }
        .frame(maxWidth: .infinity) // Expand to full screen width
        .frame(height: cardHeight) // Use the dynamic card height
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
                            self.selectedStore = nil
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
}
