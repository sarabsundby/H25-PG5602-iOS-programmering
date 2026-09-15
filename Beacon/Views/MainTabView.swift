//
//  TabView.swift
//  Beacon
//
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                ExploreView()
            }
            .tabItem {
                Label("Utforsk", systemImage: "magnifyingglass")
            }
            
            NavigationStack {
                MyPlacesView()
            }
            .tabItem {
                Label("Mine steder", systemImage: "heart.fill")
            }
        }
        .tint(Color("BeaconOrange"))
    }
}

#Preview {
    MainTabView()
}
