//
//  Item.swift
//  Kitchen_Sync
//
//  Created by Colton McCasland on 7/1/23.
//

import Foundation

import CoreData

class MyItem: NSManagedObject, Identifiable {
    @NSManaged var timestamp: Date
      @NSManaged var isChecked: Bool // Add isChecked property
    // Rest of your properties and methods
}
