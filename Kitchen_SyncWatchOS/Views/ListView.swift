//
//  ListView.swift
//  Kitchen_SyncCompanion Watch App
//
//  Created by Colton McCasland on 7/4/23.
//

import SwiftUI

struct ListView: View {
    var items: [watchItem]

    var body: some View {
        List(items) { item in
            VStack(alignment: .leading) {
                Text(item.name)
                Text(item.description)
            }
        }
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView(items: [
            watchItem(name: "Item 1", description: "Description 1"),
            watchItem(name: "Item 2", description: "Description 2"),
            watchItem(name: "Item 3", description: "Description 3")
        ])
    }
}
