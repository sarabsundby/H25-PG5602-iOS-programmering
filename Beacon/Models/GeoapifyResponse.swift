//
//  GeoapifyResponse.swift
//  Beacon
//
//

import Foundation

struct GeoapifyResponse: Codable {
    let features: [Feature]
    
    struct Feature: Codable {
        let properties: Properties
        let geometry: Geometry
        
        struct Properties: Codable {
            let placeId: String?
            let name: String?
            let formatted: String?
            let categories: [String]?
            
            enum CodingKeys: String, CodingKey {
                case placeId = "place_id"
                case name
                case formatted
                case categories
            }
        }
        
        struct Geometry: Codable {
            let coordinates: [Double]
        }
    }
}
