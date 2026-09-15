//
//  Favorite.swift
//  Beacon
//
//

import Foundation
import SwiftData

@Model
class Favorite {
    var id: UUID
    var placeId: String
    var placeName: String
    var dateAdded: Date
    
    init(placeId: String, placeName: String) {
        self.id = UUID()
        self.placeId = placeId
        self.placeName = placeName
        self.dateAdded = Date()
    }
}
