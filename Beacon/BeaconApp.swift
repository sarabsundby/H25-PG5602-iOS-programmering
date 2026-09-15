//
//  BeaconApp.swift
//  Beacon
//
//

import SwiftUI
import SwiftData


@main
struct BeaconApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(for: [Rating.self, Favorite.self])
    }
}
