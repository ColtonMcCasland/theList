// Record.swift

import Foundation

struct NodeItem: Codable, Equatable {
    let timestamp: Date
    var title: String
    var isTapped: Bool
}

extension Store {
	// Computed property to return the items of a store as an array
	var itemsArray: [GroceryItem] {
		let set = items as? Set<GroceryItem> ?? []
		return set.sorted {
			$0.name ?? "" < $1.name ?? ""
		}
	}
}
