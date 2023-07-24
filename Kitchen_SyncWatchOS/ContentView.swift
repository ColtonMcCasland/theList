// ContentView.swift

import SwiftUI
import WatchConnectivity

struct ContentView: View {
    @EnvironmentObject var watchManager: WatchManager

    var body: some View {
        List(watchManager.records.indices, id: \.self) { index in
            HStack {
                // Circle that is filled if the record is tapped
                Circle()
                    .fill(watchManager.records[index].isTapped ? Color.green : Color.red)
                    .frame(width: 20, height: 20)
                
                VStack(alignment: .leading) {
                    Text(watchManager.records[index].title)
                    Text("\(watchManager.records[index].isTapped ? "Tapped" : "Not Tapped")")
                }
            }
            .onTapGesture {
                watchManager.toggleIsTapped(for: index)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
