//
//  MyPlacesView.swift
//  Beacon
//
//

import SwiftUI
import SwiftData

struct MyPlacesView: View {
    @Query(sort: \Favorite.dateAdded, order: .reverse) private var favorites: [Favorite]
    @Query private var allRatings: [Rating]
    
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        Group {
            if favorites.isEmpty {
                emptyStateView
            } else {
                List {
                    ForEach(favorites) { favorite in
                        FavoriteRowView(favorite: favorite, rating: averageRating(for: favorite.placeId), onDelete: { deleteFavorite(favorite) }
                        )
                    }
                    .onDelete(perform: deleteFavorites)
                }
            }
        }
        .navigationTitle("Mine steder")
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.fill")
                .font(.system(size: 60))
                .foregroundColor(Color("HighlightOrange"))
                .padding()
            
            Text("Du har ingen favoritter ennå")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Utforsk steder og legg til dine favoritter ved å trykke på hjertet")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding()
    }
    
    private func averageRating(for placeId: String) -> Double {
        let placeRatings = allRatings.filter { $0.placeId == placeId }
        guard !placeRatings.isEmpty else { return 0 }
        let sum = placeRatings.reduce(0) { $0 + $1.rating }
        return Double(sum) / Double(placeRatings.count)
    }
    
    private func deleteFavorite(_ favorite: Favorite) {
        modelContext.delete(favorite)
        try? modelContext.save()
    }
    
    private func deleteFavorites(at offsets: IndexSet) {
        for index in offsets {
            let favorite = favorites[index]
            modelContext.delete(favorite)
        }
        try? modelContext.save()
    }
}

struct FavoriteRowView: View {
    let favorite: Favorite
    let rating: Double
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(favorite.placeName)
                    .font(.headline)
                
                Text("Favoritt siden \(formattedDate)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            HStack(spacing: 12) {
                if rating > 0 {
                    VStack(spacing: 4) {
                        RatingStarView(averageRating: rating, size: 20)
                        Text(String(format: "%.1f", rating))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .font(.body)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical)
    }
    
    private var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: favorite.dateAdded, relativeTo: Date())
    }
}
