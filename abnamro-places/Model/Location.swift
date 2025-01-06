
struct LocationsResponse {
  var locations: [Location]
}

struct Location: Hashable {
  var name: String?
  var latitude: Double
  var longitude: Double
}

extension LocationsResponse: Codable {}

extension Location: Codable {
  enum CodingKeys: String, CodingKey {
    case name
    case latitude = "lat"
    case longitude = "long"
  }
}
