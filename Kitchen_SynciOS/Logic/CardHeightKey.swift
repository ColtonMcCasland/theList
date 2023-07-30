import SwiftUI

struct CardHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 100

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
