import Foundation

/// A Location object, as it is returned by the github-JSON-file-based API
struct APILocation: Hashable {
  var name: String?
  var latitude: Double
  var longitude: Double
}

extension APILocation: CoordinatesConvertible {
  var coordinates: Coordinates {
    Coordinates(latitude: latitude, longitude: longitude)
  }
}

extension APILocation: Codable {
  enum CodingKeys: String, CodingKey {
    case name
    case latitude = "lat"
    case longitude = "long"
  }
}

