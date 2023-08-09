// Record.swift

import Foundation

extension Store {
	// Computed property to return the items of a store as an array
	var itemsArray: [GroceryItem] {
		let set = items as? Set<GroceryItem> ?? []
		return set.sorted {
			$0.name ?? "" < $1.name ?? ""
		}
	}
}
