//
//  LocationManager.swift
//  Beacon
//
//

import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject {
    private let manager = CLLocationManager()
    
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus?
    @Published var didJustAuthorize = false
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }
    
    func requestLocation() {
        manager.requestLocation()
    }
}


extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let oldStatus = authorizationStatus
        authorizationStatus = manager.authorizationStatus
        
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            if oldStatus == .notDetermined {
                didJustAuthorize = true
            }
            
            manager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {return}
        userLocation = location.coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}
