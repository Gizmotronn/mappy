// CheckInService.swift
// Mappy
// Created by Copilot on 15/1/2026.

import Foundation
import MapKit

struct CheckIn: Identifiable, Codable {
    let id: UUID
    let locationName: String
    let coordinate: CLLocationCoordinate2D
    let notes: String
    let timestamp: Date
    let imageUrls: [URL]
}

class CheckInService {
    static let shared = CheckInService()
    private let storageKey = "checkIns"
    
    func saveCheckIn(_ checkIn: CheckIn) {
        var all = loadCheckIns()
        all.append(checkIn)
        if let data = try? JSONEncoder().encode(all) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
    
    func loadCheckIns() -> [CheckIn] {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let checkIns = try? JSONDecoder().decode([CheckIn].self, from: data) else {
            return []
        }
        return checkIns
    }
}

extension CLLocationCoordinate2D: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(CLLocationDegrees.self, forKey: .latitude)
        let longitude = try container.decode(CLLocationDegrees.self, forKey: .longitude)
        self.init(latitude: latitude, longitude: longitude)
    }
    private enum CodingKeys: String, CodingKey {
        case latitude, longitude
    }
}
