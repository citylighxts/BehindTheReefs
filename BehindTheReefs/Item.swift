//
//  Item.swift
//  BehindTheReefs
//
//  Created by Hana Azizah Nurhadi on 05/05/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
