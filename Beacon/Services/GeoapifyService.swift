//
//  GeoapifyService.swift
//  Beacon
//
//

import Foundation

class GeoapifyService {
    // I removed my API-key before delivering
    private let apiKey = "API_KEY_HERE"
    private let baseURL = "https://api.geoapify.com/v2/places"
    
    func fetchPlaces(
        latitude: Double,
        longitude: Double,
        category: String = "catering.restaurant",
        limit: Int = 10,
        radius: Int = 5000
    ) async throws -> [Place] {
        
        guard var components = URLComponents(string: baseURL) else {
            throw URLError(.badURL)
        }
        
        let filterValue = "circle:\(longitude),\(latitude),\(radius)"
        
        components.queryItems = [
            URLQueryItem(name: "categories", value: category),
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "apiKey", value: apiKey)
        ]
        
        if let existingQuery = components.percentEncodedQuery {
            components.percentEncodedQuery = existingQuery + "&filter=" + filterValue
        } else {
            components.percentEncodedQuery = "filter=" + filterValue
        }
        
        guard let url = components.url else {
            print("Failed to create URL")
            throw URLError(.badURL)
        }
        
        print("API URL: \(url.absoluteString)")
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        print("Response status: \(httpResponse.statusCode)")
        
        guard httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        let geoapifyResponse = try decoder.decode(GeoapifyResponse.self, from: data)
        
        print("Features recieved: \(geoapifyResponse.features.count)")
        
        let places = geoapifyResponse.features.map { feature -> Place? in
            guard let name = feature.properties.name,
                  feature.geometry.coordinates.count == 2 else {
                return nil
            }
            
            let longitude = feature.geometry.coordinates[0]
            let latitude = feature.geometry.coordinates[1]
            
            return Place(
                id: feature.properties.placeId ?? UUID().uuidString ,name: name, address: feature.properties.formatted, latitude: latitude, longitude: longitude, category: category
            )
        }
        return places as! [Place]
    }
}
