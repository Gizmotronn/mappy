import Foundation

struct Poll: Codable, Identifiable {
    var id: UUID
    var title: String
    var date: Date
    var places: [PlaceOption]
    // placeID -> voterIDs
    var votes: [String: [String]]

    init(id: UUID = UUID(), title: String, date: Date, places: [PlaceOption], votes: [String: [String]] = [:]) {
        self.id = id
        self.title = title
        self.date = date
        self.places = places
        self.votes = votes
    }
}

struct PlaceOption: Codable, Identifiable, Hashable {
    var id: UUID
    var name: String
    var latitude: Double
    var longitude: Double
    var address: String

    init(id: UUID = UUID(), name: String, latitude: Double, longitude: Double, address: String) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
    }
}

enum PollCodec {
    private static let scheme = "https"
    private static let host = "meetpoll.local"
    private static let path = "/poll"

    static func encode(_ poll: Poll) -> URL? {
        guard let data = try? JSONEncoder().encode(poll) else { return nil }
        let payload = base64URLEncode(data)

        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        components.queryItems = [
            URLQueryItem(name: "payload", value: payload)
        ]
        return components.url
    }

    static func decode(from url: URL) -> Poll? {
        guard url.scheme == scheme else { return nil }
        guard url.host == host else { return nil }
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
        guard let payload = components.queryItems?.first(where: { $0.name == "payload" })?.value else { return nil }
        guard let data = base64URLDecode(payload) else { return nil }
        return try? JSONDecoder().decode(Poll.self, from: data)
    }

    private static func base64URLEncode(_ data: Data) -> String {
        let base64 = data.base64EncodedString()
        return base64
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    private static func base64URLDecode(_ value: String) -> Data? {
        var base64 = value
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let padding = 4 - (base64.count % 4)
        if padding < 4 {
            base64.append(String(repeating: "=", count: padding))
        }
        return Data(base64Encoded: base64)
    }
}
