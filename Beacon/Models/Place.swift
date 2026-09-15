//
//  Place.swift
//  Beacon
//
//

import Foundation
import CoreLocation

struct Place: Identifiable, Codable{
    var id: String
    var name: String
    var address: String?
    var latitude: Double
    var longitude: Double
    let category: String?
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(id: String, name: String, address: String?, latitude: Double, longitude: Double, category: String?) {
        self.id = id
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.category = category
    }
}
