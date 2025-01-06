import Foundation

/// Represents the top-level JSON structure of the github-JSON-file-based Locations API
struct LocationsResponse {
  var locations: [APILocation]
}

extension LocationsResponse: Codable {}
