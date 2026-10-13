//
//  Item.swift
//  SystemAwakening
//
//  Created by Vinod Kumar Singh on 12/10/26.
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
