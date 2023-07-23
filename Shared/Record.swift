// Record.swift

import Foundation

struct Record: Codable {
    let timestamp: Date
    var title: String
    var isTapped: Bool
}
