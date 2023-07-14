// WatchDataModel.swift

import SwiftUI
import Combine

class WatchDataModel: ObservableObject {
    @Published var records = [Record]()
}
