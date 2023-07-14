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
        List(watchManager.records, id: \.self) { record in
            Text("\(record.timestamp)")
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
