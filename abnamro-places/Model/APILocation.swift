
struct APILocation: Hashable {
  var name: String?
  var latitude: Double
  var longitude: Double
}

extension APILocation: Codable {
  enum CodingKeys: String, CodingKey {
    case name
    case latitude = "lat"
    case longitude = "long"
  }
}
