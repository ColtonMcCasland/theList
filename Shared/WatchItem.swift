import CoreData

class WatchItem: NSManagedObject, Encodable {
    @NSManaged var timestamp: Date

    enum CodingKeys: String, CodingKey {
        case timestamp
    }

    // Implement the encode(to:) method to encode the properties of the Item class
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(timestamp, forKey: .timestamp)
    }
}
