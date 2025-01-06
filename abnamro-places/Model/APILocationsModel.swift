import Foundation

@MainActor
@Observable
class APILocationsModel {
  let fetch: () async throws -> [APILocation]
  
  var locations: [APILocation]?
  var error: Error?
  
  init(fetch: @escaping () async throws -> [APILocation]) {
    self.fetch = fetch
  }
  
  func refresh() async {
    do {
      locations = Self.deduplicated(try await self.fetch())
      
    } catch {
      self.error = error
    }
  }
  
  /// Deduplicates locations and transforms them into `NavigableCatalogLocations` (navigable into the Wikipedia app)
  /// - Parameter locations: catalog locations, as received from an API
  /// - Returns: `NavigableCatalogLocation` values with a valid `URL`
  static func deduplicated(_ locations: [APILocation]) -> [APILocation] {
    var seen: Set<APILocation> = []
    return locations
      .filter { seen.insert($0).inserted }
  }
}

extension APILocationsModel {
  static func preview() -> APILocationsModel {
    APILocationsModel {
      [APILocation(name: "Test", latitude: 1, longitude: 2)]
    }
  }
}
