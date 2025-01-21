import Foundation
import SwiftData

/// A SwiftData entity that represents a single saved location
@Model
class SavedLocation {
  
  /// This unique constraint _should_ cause inserts of items with duplicate name or coordinates to become **upserts**, but this effect is only observed after a process restart. Therefore we also have logic in the SavedLocationsModel that prevents duplicates from being created.
  #Unique<SavedLocation>([\.name], [\.latitude, \.longitude])
  
  /// The name of the location, must not be empty when saved (enforced in the `SavedLocationsModel`)
  var name: String
  /// The latitude in degrees
  var latitude: Double
  /// The longitude in degrees
  var longitude: Double
  
  /// Creates a blank location entity with sensible default values (but might not be valid to save yet).
  /// - Parameters:
  ///   - name: The name of the location
  ///   - latitude: Latitude in degrees
  ///   - longitude: Longitude in degrees
  init(name: String = "",
       latitude: Double = 0.0,
       longitude: Double = 0.0) {
    self.name = name
    self.latitude = latitude
    self.longitude = longitude
  }
}

extension SavedLocation: CoordinatesConvertible {
  var coordinates: Coordinates {
    Coordinates(latitude: latitude, longitude: longitude)
  }
}
