// CheckInExpandedView.swift
// Mappy
// Created by Copilot on 15/1/2026.

import SwiftUI
import MapKit

struct CheckInExpandedView: View {
    @ObservedObject var searchService: CheckInLocationSearchService
    @State private var notes: String = ""
    @State private var showConfirmation: Bool = false
    var onCheckIn: ((CheckIn) -> Void)?
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Check In")
                .font(.headline)
                .padding(.top, 12)
            TextField("Search for a location", text: $searchService.queryFragment)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            if !searchService.searchResults.isEmpty {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(searchService.searchResults, id: \ .self) { completion in
                            Button(action: {
                                searchService.selectCompletion(completion)
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
                .frame(maxHeight: 120)
            }
            if let item = searchService.selectedMapItem {
                Text(item.placemark.name ?? "")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                // Image carousel
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(searchService.images, id: \ .self) { url in
                            AsyncImage(url: url) { image in
                                image.resizable().aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Color.gray.opacity(0.2)
                            }
                            .frame(width: 120, height: 80)
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            TextField("Add notes...", text: $notes)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            HStack {
                Text("Time: \(Date(), formatter: dateFormatter)")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
            }
            .padding(.horizontal)
            Button(action: {
                if let item = searchService.selectedMapItem {
                    let checkIn = CheckIn(
                        id: UUID(),
                        locationName: item.placemark.name ?? "",
                        coordinate: item.placemark.coordinate,
                        notes: notes,
                        timestamp: Date(),
                        imageUrls: searchService.images
                    )
                    CheckInService.shared.saveCheckIn(checkIn)
                    onCheckIn?(checkIn)
                    showConfirmation = true
                }
            }) {
                Text("Confirm Check In")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            .disabled(searchService.selectedMapItem == nil)
            if showConfirmation {
                Text("Check-in successful!")
                    .font(.headline)
                    .foregroundColor(.green)
                    .padding(.top, 8)
            }
        }
        .padding(.bottom, 8)
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

#Preview {
    CheckInExpandedView(searchService: CheckInLocationSearchService())
}
