//
//  ContentView.swift
//  Mappy
//
//  Created by Liam Arbuckle on 10/1/2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab: String = "map"
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Tab Views
                if selectedTab == "map" {
                    MapView()
                } else if selectedTab == "items" {
                    ItemsView(items: items, modelContext: modelContext)
                } else if selectedTab == "settings" {
                    SettingsView()
                }
                
                // Bottom Navigation Bar
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
