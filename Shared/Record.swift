// Record.swift

import Foundation

struct Record: Codable, Equatable {
    let timestamp: Date
    var title: String
    var isTapped: Bool
}
