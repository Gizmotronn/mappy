// CheckInLocationSearchService.swift
// Mappy
// Created by Copilot on 15/1/2026.

import Foundation
import MapKit
import Combine

class CheckInLocationSearchService: NSObject, ObservableObject {
    @Published var searchResults: [MKLocalSearchCompletion] = []
    @Published var queryFragment: String = "" {
        didSet {
            completer.queryFragment = queryFragment
        }
    }
    private let completer: MKLocalSearchCompleter
    @Published var selectedMapItem: MKMapItem?
    @Published var images: [URL] = []
    
    override init() {
        self.completer = MKLocalSearchCompleter()
        super.init()
        self.completer.delegate = self
        self.completer.resultTypes = .pointOfInterest
    }
    
    func selectCompletion(_ completion: MKLocalSearchCompletion) {
        let request = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            guard let self = self else { return }
            if let item = response?.mapItems.first {
                DispatchQueue.main.async {
                    self.selectedMapItem = item
                    self.fetchImages(for: item)
                }
            }
        }
    }
    
    private func fetchImages(for mapItem: MKMapItem) {
        // Apple Maps does not provide direct image URLs via MapKit.
        // For demo, use mapItem.placemark.name as a search term for Unsplash API or similar.
        // Here, we mock with static images.
        self.images = [
            URL(string: "https://images.unsplash.com/photo-1506744038136-46273834b3fb")!,
            URL(string: "https://images.unsplash.com/photo-1465101046530-73398c7f28ca")!,
            URL(string: "https://images.unsplash.com/photo-1500534314209-a25ddb2bd429")!
        ]
    }
}

extension CheckInLocationSearchService: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            self.searchResults = completer.results
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Search completer error: \(error.localizedDescription)")
    }
}
