import SwiftUI
import CoreData

struct UserListView: View {
	@Environment(\.managedObjectContext) private var viewContext
	@FetchRequest(
		entity: UserList.entity(),
		sortDescriptors: [NSSortDescriptor(keyPath: \UserList.title, ascending: true)]
	) private var users: FetchedResults<UserList>
	
	@State private var showingAddListAlert = false
	@State private var newListTitle = ""
	
	var body: some View {
		ZStack {
			NavigationView {
				Group {
					if users.isEmpty {
						Text("No lists found")
							.foregroundColor(.gray)
					} else {
						List {
							ForEach(users) { user in
								NavigationLink(destination: NotesView(userList: user)) {
									Text(user.title ?? "Unknown List")
								}
							}
							.onDelete(perform: removeList)
						}
					}
				}
				.navigationBarTitle("Lists")
				.navigationBarItems(trailing: Button(action: {
					withAnimation(.spring(response: 0.6, dampingFraction: 0.9, blendDuration: 0.4)) {
						showingAddListAlert = true
					}
				}) {
					Image(systemName: "plus")
				})
			}
			
			if showingAddListAlert {
				Color.black.opacity(0.4)
					.edgesIgnoringSafeArea(.all)
					.onTapGesture {
						withAnimation(.easeInOut(duration: 0.3)) {
							showingAddListAlert = false
						}
					}
				
				VStack {
					Text("New List")
						.font(.headline)
					TextField("Enter a title for the new list", text: $newListTitle)
						.textFieldStyle(RoundedBorderTextFieldStyle())
						.padding()
					HStack {
						Button("Cancel") {
							withAnimation(.easeInOut(duration: 0.3)) {
								showingAddListAlert = false
							}
						}
						.padding()
						Button("OK") {
							addList()
							withAnimation(.easeInOut(duration: 0.3)) {
								showingAddListAlert = false
							}
							newListTitle = ""
						}
						.padding()
					}
				}
				.padding()
				.background(Color.white)
				.cornerRadius(10)
				.shadow(radius: 10)
				.transition(.scale(scale: 0)) // Scale-in and scale-out animation
				.animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0)) // Spring animation
			}
		}
	}
	
	private func addList() {
		withAnimation {
			let newUser = UserList(context: viewContext)
			newUser.id = UUID()
			newUser.title = newListTitle
			
			do {
				try viewContext.save()
			} catch {
				let nsError = error as NSError
				fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
			}
		}
	}
	
	private func removeList(offsets: IndexSet) {
		withAnimation {
			offsets.map { users[$0] }.forEach(viewContext.delete)
			
			do {
				try viewContext.save()
			} catch {
				let nsError = error as NSError
				fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
			}
		}
	}
}
