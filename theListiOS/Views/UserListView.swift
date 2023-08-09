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
			Group {
				if users.isEmpty {
					Text("No lists found")
						.foregroundColor(.gray)
				} else {
					List {
						ForEach(users) { user in
							NavigationLink(destination: NotesView()) {
								Text(user.title ?? "Unknown List")
							}
						}
						.onDelete(perform: deleteUser)
					}
				}
			}
			.navigationBarTitle("Lists")
			.navigationBarItems(trailing: Button(action: {
				showingAddListAlert = true
			}) {
				Image(systemName: "plus")
			})
			
			if showingAddListAlert {
				Color.black.opacity(0.4)
					.edgesIgnoringSafeArea(.all)
					.onTapGesture {
						withAnimation {
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
							withAnimation {
								showingAddListAlert = false
							}
						}
						.padding()
						Button("OK") {
							addUser()
							withAnimation {
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
				.transition(.move(edge: .bottom)) // Slide-in and slide-out animation
				.animation(.default) // Apply default animation
			}
		}
	}
	
	private func addUser() {
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
	
	private func deleteUser(offsets: IndexSet) {
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
