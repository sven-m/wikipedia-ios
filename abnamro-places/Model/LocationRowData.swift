import Foundation

/// Encapsulated location -> view data translation to enable testing it separately from the view.
struct LocationRowData {
  var title: String
  var subtitle: String
  
  init(name: String?, coordinates: Coordinates, locale: Locale = .autoupdatingCurrent) {
    let latitudeString = coordinates.latitude.formatted(.number.precision(.fractionLength(7)).locale(locale))
    let longitudeString = coordinates.longitude.formatted(.number.precision(.fractionLength(7)).locale(locale))
    
    self.title = name ?? String(localized: "(untitled)")
    self.subtitle = String(localized: "Lat: \(latitudeString), Long: \(longitudeString)")
  }
}
