import Foundation

struct LocationsResponse {
  var locations: [Location]
}

extension LocationsResponse: Codable {}
