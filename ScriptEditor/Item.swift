//
//  Item.swift
//  ScriptEditor
//
//  Created by Filip Krawczyk on 21/04/2024.
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
