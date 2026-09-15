import SwiftUI
import MapKit
import SwiftData

struct PlaceDetailView: View {
    let place: Place
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Query private var allRatings: [Rating]
    @Query private var allFavorites: [Favorite]
    
    @State private var selectedRating: Int = 0
    @State private var showRatingConfirmation = false
    
    private var placeRatings: [Rating] {
        allRatings.filter { $0.placeId == place.id }
    }
    
    private var averageRating: Double {
        guard !placeRatings.isEmpty else { return 0 }
        let sum = placeRatings.reduce(0) { $0 + $1.rating }
        return Double(sum) / Double(placeRatings.count)
    }
    
    private var roundedAverageRating: Int {
        Int(round(averageRating))
    }
    
    private var isFavorite: Bool {
        allFavorites.contains { $0.placeId == place.id }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                categoryAnimation
                    .padding(.top, 20)
                
                // Rating
                VStack(spacing: 16) {
                    if !placeRatings.isEmpty {
                        VStack(spacing: 8) {
                            HStack(spacing: 8) {
                                RatingStarView(averageRating: averageRating, size: 30)
                                Text(String(format: "%.1f", averageRating))
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color("HighlightOrange"))
                            }
                            Text("\(placeRatings.count) vurdering\(placeRatings.count != 1 ? "er" : "")")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)
                    }
                    
                    VStack(spacing: 12) {
                        Text("Gi din vurdering")
                            .font(.headline)
                        
                        HStack(spacing: 12) {
                            ForEach(1...5, id: \.self) { star in
                                Button(action: {
                                    selectedRating = star
                                    saveRating(star)
                                }) {
                                    Image(systemName: star <= selectedRating ? "star.fill" : "star")
                                        .font(.system(size: 30))
                                        .foregroundColor(star <= selectedRating ? Color("HighlightOrange") : .gray)
                                }
                            }
                        }
                        
                        if showRatingConfirmation {
                            Text("Vurdering lagret!")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text(place.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    if let address = place.address, !address.isEmpty {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(Color("BeaconOrange"))
                            Text(address)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack(spacing: 8) {
                        Image(systemName: "location.circle.fill")
                            .foregroundColor(Color("BeaconOrange"))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Koordinater")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(String(format: "%.4f", place.latitude)), \(String(format: "%.4f", place.longitude))")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                    Button(action: openInMaps) {
                        HStack {
                            Image(systemName: "map.fill")
                            Text("Åpne i Apple Maps")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("BeaconOrange"))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Detaljer")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: toggleFavorite) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(isFavorite ? Color("HighlightOrange") : .gray)
                        .font(.title3)
                }
            }
        }
    }
        
    @ViewBuilder
    private var categoryAnimation: some View {
        if let category = place.category {
            if category == "catering.restaurant" || category.contains("restaurant") {
                RestaurantAnimation()
            } else if category == "catering.cafe" || category.contains("cafe") {
                CafeAnimation()
            } else if category == "accommodation.hotel" || category.contains("hotel") || category.contains("accommodation") {
                HotelAnimation()
            } else {
                Image(systemName: "fork.knife")
                    .font(.system(size: 80))
                    .foregroundColor(Color("BeaconOrange"))
            }
        }
    }
    
    
    private func saveRating(_ rating: Int) {
        let newRating = Rating(placeId: place.id, placeName: place.name, rating: rating)
        modelContext.insert(newRating)
        
        try? modelContext.save()
        
        showRatingConfirmation = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showRatingConfirmation = false
            selectedRating = 0
        }
    }
    
    private func toggleFavorite() {
        if let existingFavorite = allFavorites.first(where: { $0.placeId == place.id }) {
            modelContext.delete(existingFavorite)
        } else {
            let newFavorite = Favorite(placeId: place.id, placeName: place.name)
            modelContext.insert(newFavorite)
        }
        
        try? modelContext.save()
    }
    
    private func openInMaps() {
        let location = CLLocation(latitude: place.latitude, longitude: place.longitude)
        let mapItem = MKMapItem(location: location, address: nil)
        mapItem.name = place.name
        mapItem.openInMaps(launchOptions: [:])
    }
}
