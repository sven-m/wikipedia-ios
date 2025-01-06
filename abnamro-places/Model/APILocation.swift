import Foundation

struct APILocation: Hashable, CoordinatesConvertible {
  var name: String?
  var latitude: Double
  var longitude: Double
  
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

