// Record.swift

import Foundation

struct NodeItem: Codable, Equatable {
    let timestamp: Date
    var title: String
    var isTapped: Bool
}
