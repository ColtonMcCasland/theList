import Foundation

struct KitchenSyncRecord: Codable, Identifiable {
    let id: UUID
    let name: String
    let date: Date
    // Add any other properties you need...
}
