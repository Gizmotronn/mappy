import Foundation
import MapKit
import Combine

final class PollViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var date: Date = Date().addingTimeInterval(3600)
    @Published var places: [PlaceOption] = []
    @Published var votes: [String: [String]] = [:]
    @Published var isLoading: Bool = false
    @Published var statusMessage: String?
    @Published var isViewingPoll: Bool = false
    @Published var debugInfo: String?

    func load(poll: Poll) {
        title = poll.title
        date = poll.date
        places = poll.places
        votes = poll.votes
        isViewingPoll = true
        statusMessage = nil
    }

    func buildPoll() -> Poll {
        Poll(title: title.isEmpty ? "Meetup" : title, date: date, places: places, votes: votes)
    }

    func addPlace(from mapItem: MKMapItem) {
        let name = mapItem.name ?? "Untitled Place"
        let coordinate = mapItem.placemark.coordinate
        let address = [
            mapItem.placemark.name,
            mapItem.placemark.thoroughfare,
            mapItem.placemark.locality,
            mapItem.placemark.administrativeArea
        ]
        .compactMap { $0 }
        .joined(separator: ", ")

        let option = PlaceOption(
            name: name,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            address: address
        )
        if !places.contains(option) {
            places.append(option)
        }
    }

    func removePlace(_ place: PlaceOption) {
        places.removeAll { $0.id == place.id }
        votes.removeValue(forKey: place.id.uuidString)
    }

    func reset() {
        title = ""
        date = Date().addingTimeInterval(3600)
        places = []
        votes = [:]
        isViewingPoll = false
        statusMessage = nil
    }

    func toggleVote(placeId: UUID, voterId: String) {
        let key = placeId.uuidString
        var set = Set(votes[key] ?? [])
        if set.contains(voterId) {
            set.remove(voterId)
        } else {
            set.insert(voterId)
        }
        votes[key] = Array(set)
    }

    func voteCount(for placeId: UUID) -> Int {
        votes[placeId.uuidString]?.count ?? 0
    }

    func hasVoted(placeId: UUID, voterId: String) -> Bool {
        (votes[placeId.uuidString] ?? []).contains(voterId)
    }
}
