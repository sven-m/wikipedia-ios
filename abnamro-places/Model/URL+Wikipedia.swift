import Foundation

private let locale = Locale(identifier: "en_US_POSIX")

extension URL {
  /// Create a deep-link into the Wikipedia app that makes the Wikipedia show the coordinates in the Places-tab
  ///
  /// This method can probably be changed to a non-null value, because according to the Apple documentation,
  /// the implementation's uage will always lead to a non-null URL value. However, this might need a bit of
  /// discussion before moving to using force unwrapping.
  ///
  /// - Parameter coordinates: the coordinates to show in the Wikipedia app
  /// - Returns: a URL that, when opened, will trigger the Wikipedia app to be launched.
  static func wikipediaURL(coordinates: Coordinates) -> Self? {
    let latitudeString = coordinates.latitude.formatted(.number.locale(locale))
    let longitudeString = coordinates.longitude.formatted(.number.locale(locale))
    
    var components = URLComponents()
    components.scheme = "wikipedia"
    components.host = "places"
    components.queryItems = [
      URLQueryItem(
        name: "WMFPlacesLatLong",
        value: "\(latitudeString),\(longitudeString)")
    ]
    
    return components.url
  }
}
