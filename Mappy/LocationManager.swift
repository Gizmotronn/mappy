//
//  LocationManager.swift
//  Mappy
//
//  Created by Liam Arbuckle on 10/1/2026.
//

import Foundation
import Combine
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    private let locationManager = CLLocationManager()
    @Published var userLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = locationManager.authorizationStatus
    }
    
    func requestLocation() {
        // Check current status first
        let currentStatus = locationManager.authorizationStatus
        
        if currentStatus == .notDetermined {
            // Only request if we haven't asked before
            locationManager.requestWhenInUseAuthorization()
        } else if currentStatus == .authorizedWhenInUse || currentStatus == .authorizedAlways {
            // Already authorized, start updates
            locationManager.startUpdatingLocation()
        } else if currentStatus == .denied || currentStatus == .restricted {
            // Denied or restricted - user needs to change in Settings
            print("Location access is denied. Please enable it in Settings.")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
}
