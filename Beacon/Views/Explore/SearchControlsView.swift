//
//  SearchControlsView.swift
//  Beacon
//
//

import SwiftUI

struct SearchControlsView: View {
    @Binding var searchText: String
    @Binding var searchRadius: Double
    @Binding var sortOption: SortOption
    @Binding var showFavoritesOnly: Bool
    
    var onClear: () -> Void
    
    enum SortOption: String, CaseIterable {
        case distance = "Avstand"
        case rating = "Vurdering"
        case alphabetical = "A-Å"
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Search bar
            SearchBarView(searchText: $searchText) {
            }
            
            // Radius slider
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Søkeradius:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(Int(searchRadius)) km")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("BeaconOrange"))
                }
                
                Slider(value: $searchRadius, in: 1...10, step: 1)
                    .tint(Color("BeaconOrange"))
            }
            
            // Sort and Filter options
            HStack(spacing: 12) {
                Menu {
                    Picker("Sorter", selection: $sortOption) {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "arrow.up.arrow.down")
                        Text(sortOption.rawValue)
                            .font(.subheadline)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color("BeaconOrange").opacity(0.2))
                    .foregroundColor(Color("BeaconOrange"))
                    .cornerRadius(8)
                }
                
                // Favorites toggle
                Button(action: { showFavoritesOnly.toggle() }) {
                    HStack {
                        Image(systemName: showFavoritesOnly ? "heart.fill" : "heart")
                        Text("Vis favoritter")
                            .font(.subheadline)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(showFavoritesOnly ? Color("HighlightOrange") : Color.gray.opacity(0.2))
                    .foregroundColor(showFavoritesOnly ? .white : .primary)
                    .cornerRadius(8)
                }
                
                Spacer()
                
                Button(action: onClear) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .shadow(radius: 4)
        .padding(.horizontal)
        .padding(.top, 10)
    }
}
