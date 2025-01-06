import Foundation

@Observable
class APILocationsModel {
  let fetch: () async throws -> [Location]
  
  var locations: [Location]?
  var error: Error?
  
  init(fetch: @escaping () async throws -> [Location]) {
    self.fetch = fetch
  }
  
  func refresh() async {
    do {
      locations = deduplicated(try await self.fetch())

    } catch {
      self.error = error
    }
  }
  
  /// Deduplicates locations and transforms them into `NavigableCatalogLocations` (navigable into the Wikipedia app)
  /// - Parameter locations: catalog locations, as received from an API
  /// - Returns: `NavigableCatalogLocation` values with a valid `URL`
  func deduplicated(_ locations: [Location]) -> [Location] {
    var seen: Set<Location> = []
    return locations
      .filter { seen.insert($0).inserted }
  }
}

extension APILocationsModel {
  static func preview() -> APILocationsModel {
    APILocationsModel {
      [Location(name: "Test", latitude: 1, longitude: 2)]
    }
  }
}
