import Foundation



extension URL {
  
  static func wikipediaURL(latitude: Double, longitude: Double) -> Self? {
    var components = URLComponents()
    components.scheme = "wikipedia"
    components.host = "places"
    components.queryItems = [
      URLQueryItem(
        name: "WMFPlacesLatLong",
        value: "\(latitude),\(longitude)")
    ]
    
    return components.url
  }
}
