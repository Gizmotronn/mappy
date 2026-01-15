//
//  ContentView.swift
//  Mappy
//
//  Created by Liam Arbuckle on 10/1/2026.
//

import SwiftUI
import SwiftData
import MapKit
import CoreLocation

// Helper for UserDefaults persistence
extension CLLocationCoordinate2D {
    static let persistedKey = "selectedLocationCoordinate"
    func saveToDefaults() {
        let dict = ["lat": self.latitude, "lon": self.longitude]
        UserDefaults.standard.set(dict, forKey: Self.persistedKey)
    }
    static func loadFromDefaults() -> CLLocationCoordinate2D? {
        guard let dict = UserDefaults.standard.dictionary(forKey: Self.persistedKey) as? [String: CLLocationDegrees],
              let lat = dict["lat"], let lon = dict["lon"] else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}

struct ContentView: View {
    @State private var selectedTab: String = "map"
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @State private var mapPosition: MapCameraPosition = {
        if let coord = CLLocationCoordinate2D.loadFromDefaults() {
            return .region(MKCoordinateRegion(center: coord, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)))
        } else {
            return .region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: -33.8688, longitude: 151.2093), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)))
        }
    }()
    @State private var selectedLocation: CLLocationCoordinate2D? = CLLocationCoordinate2D.loadFromDefaults()
    @State private var isCheckInExpanded: Bool = false

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // Tab Views
                if selectedTab == "map" {
                    MapView(position: $mapPosition)
                } else if selectedTab == "items" {
                    ItemsView(items: items, modelContext: modelContext)
                } else if selectedTab == "settings" {
                    SettingsView(selectedLocation: selectedLocation, onLocationSelected: { coordinate in
                        selectedLocation = coordinate
                        coordinate.saveToDefaults()
                        withAnimation {
                            mapPosition = .region(MKCoordinateRegion(
                                center: coordinate,
                                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                            ))
                        }
                        selectedTab = "map"
                    })
                }
                ZStack(alignment: .top) {
                    HStack(spacing: 0) {
                        TabBarItem(
                            icon: "map.fill",
                            label: "Map",
                            isSelected: selectedTab == "map"
                        ) {
                            selectedTab = "map"
                        }
                        TabBarItem(
                            icon: "list.bullet",
                            label: "Items",
                            isSelected: selectedTab == "items"
                        ) {
                            selectedTab = "items"
                        }
                        TabBarItem(
                            icon: "gear",
                            label: "Settings",
                            isSelected: selectedTab == "settings"
                        ) {
                            selectedTab = "settings"
                        }
                    }
                    .frame(height: 70)
                    .background(Color(UIColor.systemBackground))
                    .border(Color.gray.opacity(0.3), width: 1)
                    CheckInOverlay(isExpanded: $isCheckInExpanded)
                        .padding(.horizontal, 16)
                        .offset(y: -24)
                        .animation(.easeInOut, value: isCheckInExpanded)
                }
            }
        }
    }
}

struct TabBarItem: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                Text(label)
                    .font(.caption2)
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(isSelected ? .blue : .gray)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
