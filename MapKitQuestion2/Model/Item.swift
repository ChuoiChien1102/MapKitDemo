//
//  Item.swift
//  MapKitQuestion2
//
//  Created by Nguyen Van Chien on 4/10/24.
//

import UIKit

class Item: NSObject {
    var name: String
    var point: Int = 0
    init(name: String, point: Int) {
        self.name = name
        self.point = point
        super.init()
    }
}
