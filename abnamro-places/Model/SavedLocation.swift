import Foundation
import SwiftData

@Model
class SavedLocation {
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
}

extension SavedLocation {
  var isValid: Bool {
    !name.isEmpty
    && (-90...90).contains(latitude)
    && (-180...180).contains(longitude)
  }
}
