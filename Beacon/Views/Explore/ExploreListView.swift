//
//  ExploreListView.swift
//  Beacon
//
//

import SwiftUI
import SwiftData

struct ExploreListView: View {
    let places: [Place]
    let allRatings: [Rating]
    let allFavorites: [Favorite]
    let isLoading: Bool
    let showFavoritesOnly: Bool
    let searchText: String
    let categoryDisplayName: String
    
    var onRefresh: () async -> Void
    var onToggleFavorite: (Place) -> Void
    
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        Group {
            if places.isEmpty {
                emptyStateView
            } else {
                List {
                    ForEach(places) { place in
                        NavigationLink(destination: PlaceDetailView(place: place)) {
                            PlaceRowView(
                                place: place,
                                rating: averageRating(for: place.id),
                                isFavorite: isFavorite(place.id),
                                onToggleFavorite: { onToggleFavorite(place) }
                            )
                        }
                    }
                }
                .refreshable {
                    await onRefresh()
                }
            }
        }
    }
        
    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            if isLoading {
                ProgressView()
                    .scaleEffect(1.5)
            } else if showFavoritesOnly && allFavorites.isEmpty {
                EmptyStateContent(
                    icon: "heart.slash",
                    title: "Ingen favoritter ennå",
                    subtitle: "Trykk hjertet for å legge til favoritter"
                )
            } else if !searchText.isEmpty {
                EmptyStateContent(
                    icon: "magnifyingglass",
                    title: "Ingen treff",
                    subtitle: "Prøv et annet søk"
                )
            } else {
                EmptyStateContent(
                    icon: "map",
                    title: "Ingen steder å vise",
                    subtitle: "Trykk 'Hent steder' på kartvisningen for å finne \(categoryDisplayName.lowercased()) i nærheten"
                )
            }
        }
        .padding()
    }
    
    
    private func averageRating(for placeId: String) -> Double {
        let placeRatings = allRatings.filter { $0.placeId == placeId }
        guard !placeRatings.isEmpty else { return 0 }
        let sum = placeRatings.reduce(0) { $0 + $1.rating }
        return Double(sum) / Double(placeRatings.count)
    }
    
    private func isFavorite(_ placeId: String) -> Bool {
        allFavorites.contains { $0.placeId == placeId }
    }
}

struct PlaceRowView: View {
    let place: Place
    let rating: Double
    let isFavorite: Bool
    let onToggleFavorite: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(place.name)
                    .font(.headline)
                
                if let address = place.address, !address.isEmpty {
                    Text(address)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
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
                
                Button(action: onToggleFavorite) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(isFavorite ? Color("HighlightOrange") : .gray)
                        .font(.title3)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
    }
}

struct EmptyStateContent: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}
