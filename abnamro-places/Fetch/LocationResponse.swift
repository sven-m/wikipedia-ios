import Foundation

struct LocationsResponse {
  var locations: [APILocation]
}

extension LocationsResponse: Codable {}
