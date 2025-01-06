import Foundation
import SwiftData

@Model
class SavedLocation: CoordinatesConvertible {
  #Unique<SavedLocation>([\.name], [\.latitude, \.longitude])
  
  var name: String
  var latitude: Double
  var longitude: Double
  
  init(name: String = "",
       latitude: Double = 0.0,
       longitude: Double = 0.0) {
    self.name = name
    self.latitude = latitude
    self.longitude = longitude
  }
  
  var coordinates: Coordinates {
    Coordinates(latitude: latitude, longitude: longitude)
  }
}
