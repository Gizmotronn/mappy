//
//  SettingsView.swift
//  Mappy
//
//  Created by Liam Arbuckle on 10/1/2026.
//

import SwiftUI
import CoreLocation
import MapKit

struct SettingsView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var searchService = LocationSearchService()
    @State private var selectedCompletion: MKLocalSearchCompletion?
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    var selectedLocation: CLLocationCoordinate2D?
    var onLocationSelected: ((CLLocationCoordinate2D) -> Void)? = nil

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

                    // Location search dropdown
                    VStack(alignment: .leading) {
                        Text("Select Suburb/City")
                            .font(.headline)
                        TextField("Search for a location", text: $searchService.queryFragment)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        if !searchService.searchResults.isEmpty {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 0) {
                                    ForEach(searchService.searchResults, id: \ .self) { completion in
                                        Button(action: {
                                            selectedCompletion = completion
                                            // Perform search to get coordinate
                                            let request = MKLocalSearch.Request(completion: completion)
                                            let search = MKLocalSearch(request: request)
                                            search.start { response, error in
                                                if let coordinate = response?.mapItems.first?.placemark.coordinate {
                                                    selectedCoordinate = coordinate
                                                    onLocationSelected?(coordinate)
                                                }
                                            }
                                            // Clear search results after selection
                                            searchService.queryFragment = completion.title
                                            searchService.searchResults = []
                                        }) {
                                            VStack(alignment: .leading) {
                                                Text(completion.title)
                                                    .font(.body)
                                                if !completion.subtitle.isEmpty {
                                                    Text(completion.subtitle)
                                                        .font(.caption)
                                                        .foregroundColor(.gray)
                                                }
                                            }
                                            .padding(.vertical, 6)
                                            .padding(.horizontal, 4)
                                        }
                                        Divider()
                                    }
                                }
                            }
                            .frame(maxHeight: 150)
                        }
                        if let selectedCompletion = selectedCompletion {
                            Text("Selected: \(selectedCompletion.title)")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        } else if let selectedLocation = selectedLocation {
                            Text(String(format: "Selected: %.4f, %.4f", selectedLocation.latitude, selectedLocation.longitude))
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }

#Preview {
    SettingsView()
}
