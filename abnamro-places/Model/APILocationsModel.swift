import Foundation


/// The APILocationModel is responsible for obtaining the locations from an (injected) API dependency
/// and ensures the locations are deduplicated.
///
/// I chose to add some contrived functionality to give this class a reason to exist for the purpose of
/// illustration. I could also have left out a model for the APILocationsView, and not having a model class in
/// this particular case can be a logical alternative.
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
  
  static func deduplicated(_ locations: [APILocation]) -> [APILocation] {
    var seen: Set<APILocation> = []
    return locations
      .filter { seen.insert($0).inserted }
  }
}

extension APILocationsModel {
  /// Creates instance of the model that returns fake data, useful for SwiftUI previews
  /// - Returns: the model with a mocked fetch function
  static func preview() -> APILocationsModel {
    APILocationsModel {
      [APILocation(name: "Test", latitude: 1, longitude: 2)]
    }
  }
}
