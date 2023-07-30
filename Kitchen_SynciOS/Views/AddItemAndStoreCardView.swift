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
    @GestureState private var dragOffset: CGFloat = 0.0 // Track the total drag offset

    var body: some View {
        ZStack(alignment: .top) {
            VStack {
                TextField("New item name", text: $newItemName)
                    .padding()
                    .opacity(isAddItemAndStoreVisible ? 1 : 0)
                if selectedStore == nil {
                    TextField("New store name", text: $newStoreName)
                        .padding()
                        .opacity(isAddItemAndStoreVisible ? 1 : 0)
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
                .opacity(isAddItemAndStoreVisible ? 1 : 0)
                .disabled(newItemName.isEmpty || (newStoreName.isEmpty && selectedStore == nil))
                .padding()
            }
            .frame(maxWidth: .infinity)
            .frame(height: isAddItemAndStoreVisible ? 300 : 100)
            .padding(.bottom, isAddItemAndStoreVisible ? 70 : 15)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(radius: 5)
            .offset(y: dragOffset)
            .gesture(DragGesture()
                .updating($dragOffset) { value, state, _ in
                    state = value.translation.height
                }
                .onEnded { gesture in
                    let offsetY = gesture.translation.height
                    if offsetY > 100 {
                        withAnimation(.spring()) {
                            isAddItemAndStoreVisible = false
                        }
                        dismissKeyboard() // Close the keyboard when the menu is closed
                    } else if offsetY < -100 {
                        withAnimation(.spring()) {
                            isAddItemAndStoreVisible = true
                        }
                    }
                }
            )

            Button(action: {
                withAnimation(.spring()) {
                    self.isAddItemAndStoreVisible.toggle()
                    if !isAddItemAndStoreVisible {
                        self.newItemName = ""
                        self.newStoreName = ""
                        self.selectedStore = nil
                        if isKeyboardShowing {
                            dismissKeyboard()
                        }
                    }
                }
            }) {
                Image(systemName: "chevron.down")
                    .resizable()
                    .frame(width: 80, height: 16)
                    .rotation3DEffect(isAddItemAndStoreVisible ? Angle(degrees: 180) : Angle(degrees: 0), axis: (x: 1, y: 0, z: 0))
                    .scaleEffect(isAddItemAndStoreVisible ? 1.3 : 1.0)
            }
            .padding()
            .background(Color.white)
            .clipShape(Circle())
            .alignmentGuide(.top) { d in d[.bottom] - 50 }
            .offset(y: dragOffset)
        }
        .frame(height: isAddItemAndStoreVisible ? 300 : 50)
        .animation(.spring(), value: isAddItemAndStoreVisible)
        .onChange(of: isAddItemAndStoreVisible) { newValue in
            if !newValue {
                dismissKeyboard() // Close the keyboard when the menu is closed
            }
        }
    }

    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
