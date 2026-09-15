//
//  ExploreMapView.swift
//  Beacon
//
//

import SwiftUI
import MapKit
import SwiftData

struct ExploreMapView: View {
    @Binding var cameraPosition: MapCameraPosition
    @Binding var mapCenterLat: Double
    @Binding var mapCenterLon: Double
    
    let places: [Place]
    let allRatings: [Rating]
    
    var body: some View {
        Map(position: $cameraPosition) {
            ForEach(places) { place in
                Annotation(place.name, coordinate: place.coordinate) {
                    NavigationLink(destination: PlaceDetailView(place: place)) {
                        VStack(spacing: 2) {
                            VStack(spacing: 0) {
                                ZStack {
                                    Circle()
                                        .fill(Color("HighlightOrange"))
                                        .frame(width: 28, height: 28)
                                        .shadow(color: .black.opacity(0.3), radius: 3)
                                    
                                    Image(systemName: "pin.fill")
                                        .font(.system(size:12))
                                        .foregroundColor(Color("DeepBlue"))
                                }
                                
                                Triangle()
                                    .fill(Color("HighlightOrange"))
                                    .frame(width: 14, height: 10)
                                    .overlay(
                                        Triangle()
                                            .stroke(Color("HighlightOrange"), lineWidth: 3)
                                    )
                                    .offset(y: -1)
                            }
                            
                            // Rating
                            let rating = averageRating(for: place.id)
                            if rating > 0 {
                                RatingStarView(averageRating: rating, size: 16)
                                    .background(
                                        Circle()
                                            .fill(.white)
                                            .frame(width: 24, height: 24)
                                    )
                                    .offset(y: -2)
                            }
                        }
                    }
                }
            }
        }
        .mapStyle(.standard)
        .onMapCameraChange { context in
            mapCenterLat = context.region.center.latitude
            mapCenterLon = context.region.center.longitude
        }
    }
    
    private func averageRating(for placeId: String) -> Double {
        let placeRatings = allRatings.filter { $0.placeId == placeId }
        guard !placeRatings.isEmpty else { return 0 }
        let sum = placeRatings.reduce(0) { $0 + $1.rating }
        return Double(sum) / Double(placeRatings.count)
    }
}
