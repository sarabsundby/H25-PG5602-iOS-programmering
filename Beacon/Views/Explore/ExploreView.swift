//
//  ExploreView.swift
//  Beacon
//
//

import SwiftUI
import MapKit
import SwiftData

struct ExploreView: View {
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 59.9111, longitude: 10.7503),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )
    
    @AppStorage("mapCenterLat") private var mapCenterLat: Double = 59.9111
    @AppStorage("mapCenterLon") private var mapCenterLon: Double = 10.7503
    @AppStorage("searchRadius") private var searchRadius: Double = 5.0
    
    @State private var places: [Place] = []
    @State private var filteredPlaces: [Place] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showList = false
    @State private var selectedCategory = "catering.restaurant"
    
    @State private var searchText = ""
    @State private var searchTask: Task<Void, Never>?
    @State private var sortOption: SearchControlsView.SortOption = .distance
    @State private var showSearchControls = false
    @State private var showFavoritesOnly = false
    
    @StateObject private var locationManager = LocationManager()
    @Environment(\.modelContext) private var modelContext
    
    @Query private var allRatings: [Rating]
    @Query private var allFavorites: [Favorite]
    
    private let geoapifyService = GeoapifyService()
    
    var body: some View {
        ZStack {
            if showList {
                ExploreListView(
                    places: filteredPlaces,
                    allRatings: allRatings,
                    allFavorites: allFavorites,
                    isLoading: isLoading,
                    showFavoritesOnly: showFavoritesOnly,
                    searchText: searchText,
                    categoryDisplayName: categoryDisplayName,
                    onRefresh: { await fetchPlacesAsync() },
                    onToggleFavorite: toggleFavorite
                )
            } else {
                mapViewWithControls
            }
        }
        .navigationTitle("Utforsk")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                        showSearchControls.toggle()
                }) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color("BeaconOrange"))
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { showList.toggle() }) {
                    Image(systemName: showList ? "map.fill" : "list.bullet")
                        .foregroundColor(Color("BeaconOrange"))
                }
            }
        }
        .alert("Feil", isPresented: .constant(errorMessage != nil)) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
        .onAppear {
            updateMapPosition()
            updateFilteredPlaces()
        }
        .onChange(of: searchText) { oldValue, newValue in
            debounceSearch()
        }
        .onChange(of: sortOption) { oldValue, newValue in
            updateFilteredPlaces()
        }
        .onChange(of: showFavoritesOnly) { oldValue, newValue in
            updateFilteredPlaces()
        }
    }
    
    private var mapViewWithControls: some View {
        ZStack {
            ExploreMapView(
                cameraPosition: $cameraPosition,
                mapCenterLat: $mapCenterLat,
                mapCenterLon: $mapCenterLon,
                places: filteredPlaces,
                allRatings: allRatings
            )
            
            // Loading overlay
            if isLoading {
                loadingOverlay
            }
            
            // Controls
            VStack {
                    if showSearchControls {
                        SearchControlsView(searchText: $searchText, searchRadius: $searchRadius, sortOption: $sortOption, showFavoritesOnly: $showFavoritesOnly, onClear: clearFilters
                        )
                        .transition(.move(edge: .top).combined(with: .opacity))
                        
                }
            topControls
            Spacer()
            
                HStack {
                    Spacer()
                    gpsButton
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                }
            }
        }
    }
    
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea(.all)
            
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(Color("BeaconOrange"))
                Text("Henter steder...")
                    .foregroundColor(.white)
                    .font(.headline)
            }
            .padding(30)
            .background(Color("DeepBlue").opacity(0.95))
            .cornerRadius(16)
        }
    }
    
    private var topControls: some View {
        HStack(spacing: 12) {
            Picker("Kategori", selection: $selectedCategory) {
                Text("Restauranter").tag("catering.restaurant")
                Text("Kafeer").tag("catering.cafe")
                Text("Hoteller").tag("accommodation.hotel")
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 300)
            
            Button(action: fetchPlaces) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Hent steder")
                            .fontWeight(.semibold)
                    }
                }
                .frame(minWidth: 100)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color("BeaconOrange"))
            .disabled(isLoading)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .shadow(radius: 4)
        .padding(.horizontal)
        .padding(.top, 10)
    }
    
    private var gpsButton: some View {
        Button(action: findNearMe) {
            Image(systemName: "location.fill")
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 50, height: 50)
                .background(Color("DeepBlue"))
                .clipShape(Circle())
                .shadow(radius: 4)
        }
    }
    
    // Functions
    
    private func fetchPlaces() {
        Task {
            isLoading = true
            errorMessage = nil
            
            do {
                places = try await geoapifyService.fetchPlaces(
                    latitude: mapCenterLat,
                    longitude: mapCenterLon,
                    category: selectedCategory,
                    limit: 20,
                    radius: Int(searchRadius * 1000)
                )
                updateFilteredPlaces()
            } catch {
                errorMessage = "Kunne ikke hente steder: \(error.localizedDescription)"
            }
            
            isLoading = false
        }
    }
    
    private func fetchPlacesAsync() async {
        fetchPlaces()
    }
    
    private func updateFilteredPlaces() {
        var result = places
        
        if !searchText.isEmpty {
            result = result.filter { place in
                place.name.localizedCaseInsensitiveContains(searchText) ||
                (place.address?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        if showFavoritesOnly {
            let favoriteIds = allFavorites.map { $0.placeId }
            result = result.filter { favoriteIds.contains($0.id) }
        }
        
        switch sortOption {
        case .distance:
            result = sortByDistance(result)
        case .rating:
            result = sortByRating(result)
        case .alphabetical:
            result = result.sorted { $0.name < $1.name }
        }
        
        filteredPlaces = result
    }
    
    private func sortByDistance(_ places: [Place]) -> [Place] {
        let center = CLLocation(latitude: mapCenterLat, longitude: mapCenterLon)
        return places.sorted { place1, place2 in
            let loc1 = CLLocation(latitude: place1.latitude, longitude: place1.longitude)
            let loc2 = CLLocation(latitude: place2.latitude, longitude: place2.longitude)
            return center.distance(from: loc1) < center.distance(from: loc2)
        }
    }
    
    private func sortByRating(_ places: [Place]) -> [Place] {
        return places.sorted { place1, place2 in
            let rating1 = averageRating(for: place1.id)
            let rating2 = averageRating(for: place2.id)
            return rating1 > rating2
        }
    }
    
    private func averageRating(for placeId: String) -> Double {
        let placeRatings = allRatings.filter { $0.placeId == placeId }
        guard !placeRatings.isEmpty else { return 0 }
        let sum = placeRatings.reduce(0) { $0 + $1.rating }
        return Double(sum) / Double(placeRatings.count)
    }
    
    private func toggleFavorite(for place: Place) {
        if let existingFavorite = allFavorites.first(where: { $0.placeId == place.id }) {
            modelContext.delete(existingFavorite)
        } else {
            let newFavorite = Favorite(placeId: place.id, placeName: place.name)
            modelContext.insert(newFavorite)
        }
        
        try? modelContext.save()
        updateFilteredPlaces()
    }
    
    private func clearFilters() {
        searchText = ""
        searchRadius = 5.0
        sortOption = .distance
        showFavoritesOnly = false
        selectedCategory = "catering.restaurant"
        updateFilteredPlaces()
    }
    
    private func debounceSearch() {
        searchTask?.cancel()
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            if !Task.isCancelled {
                updateFilteredPlaces()
            }
        }
    }
    
    private func findNearMe() {
        let status = locationManager.authorizationStatus ?? .notDetermined
        
        switch status {
        case .notDetermined:
            locationManager.requestPermission()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if let userLoc = locationManager.userLocation {
                    withAnimation {
                        cameraPosition = .region(
                            MKCoordinateRegion(
                                center: userLoc,
                                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                            )
                        )
                    }
                    mapCenterLat = userLoc.latitude
                    mapCenterLon = userLoc.longitude
                    fetchPlaces()
                }
            }
        case .denied, .restricted:
            errorMessage = "Posisjonstilgang er nødvendig"
        @unknown default:
            break
        }
    }
    
    private func updateMapPosition() {
        cameraPosition = .region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: mapCenterLat, longitude: mapCenterLon),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        )
    }
    
    private var categoryDisplayName: String {
        switch selectedCategory {
        case "catering.restaurant": return "Restauranter"
        case "catering.cafe": return "Kafeer"
        case "accommodation.hotel": return "Hoteller"
        default: return "Steder"
        }
    }
}
