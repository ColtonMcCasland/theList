//
//  ContentView.swift
//  Kitchen_Sync
//
//  Created by Colton McCasland on 7/8/23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataFetcher: DataFetcher

    var body: some View {
        Text("Hello, World!")
            .onAppear {
                print("Container: \(dataFetcher.container)")
                print("Database: \(dataFetcher.database)")
            }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
