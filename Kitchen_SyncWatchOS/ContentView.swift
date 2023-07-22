//
//  ContentView.swift
//  Kitchen_Sync
//
//  Created by Colton McCasland on 7/8/23.
//

import SwiftUI
import WatchConnectivity

struct ContentView: View {
    @EnvironmentObject var watchManager: WatchManager

    var body: some View {
        List(watchManager.records.indices, id: \.self) { index in
            VStack(alignment: .leading) {
                Text(watchManager.records[index].title)
                Text("\(watchManager.records[index].isTapped ? "Tapped" : "Not Tapped")")
                Text("\(watchManager.records[index].timestamp)")
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
