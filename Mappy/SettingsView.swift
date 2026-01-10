//
//  SettingsView.swift
//  Mappy
//
//  Created by Liam Arbuckle on 10/1/2026.
//

import SwiftUI
import CoreLocation

struct SettingsView: View {
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        NavigationStack {
            List {
                Section("Location") {
                    Button(action: {
                        locationManager.requestLocation()
                    }) {
                        HStack {
                            Text("Location Services")
                            Spacer()
                            Image(systemName: locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways ? .green : .gray)
                        }
                    }
                    
                    if locationManager.authorizationStatus == .denied {
                        Text("Location access is denied. Tap above to enable or change settings in the Settings app.")
                            .font(.caption)
                            .foregroundColor(.orange)
                    } else if locationManager.authorizationStatus == .notDetermined {
                        Text("Tap above to request location access.")
                            .font(.caption)
                            .foregroundColor(.gray)
                    } else {
                        Text("Location services enabled")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
