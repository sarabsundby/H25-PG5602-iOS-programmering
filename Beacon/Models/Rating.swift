//
//  Rating.swift
//  Beacon
//
//

import Foundation
import SwiftData

@Model
class Rating {
    var id: UUID
    var placeId: String
    var placeName: String
    var rating: Int
    var date: Date
    
    init(placeId: String, placeName: String, rating: Int) {
        self.id = UUID()
        self.placeId = placeId
        self.placeName = placeName
        self.rating = rating
        self.date = Date()
        
    }
}
