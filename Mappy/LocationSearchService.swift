// LocationSearchService.swift
// Mappy
//
// Created by Liam Arbuckle on 15/1/2026.
//

import Foundation
import MapKit
import Combine

class LocationSearchService: NSObject, ObservableObject {
    @Published var searchResults: [MKLocalSearchCompletion] = []
    @Published var queryFragment: String = "" {
        didSet {
            completer.queryFragment = queryFragment
        }
    }
    private let completer: MKLocalSearchCompleter
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        self.completer = MKLocalSearchCompleter()
        super.init()
        self.completer.delegate = self
        self.completer.resultTypes = .address
    }
}

extension LocationSearchService: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            self.searchResults = completer.results
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Search completer error: \(error.localizedDescription)")
    }
}
