import Foundation

extension URL {
  static func wikipediaURL(coordinates: Coordinates) -> Self? {
    var components = URLComponents()
    components.scheme = "wikipedia"
    components.host = "places"
    components.queryItems = [
      URLQueryItem(
        name: "WMFPlacesLatLong",
        value: "\(coordinates.latitude),\(coordinates.longitude)")
    ]
    
    return components.url
  }
}
