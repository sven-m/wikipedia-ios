@objc extension CLLocation {
  convenience init?(commaSeparatedString string: String) {
    let components = string.split(separator: ",")
    
    guard components.count == 2,
          let latitude = CLLocationDegrees(components[0]),
          let longitude = CLLocationDegrees(components[1]) else {
      return nil
    }
    
    self.init(latitude: latitude, longitude: longitude)
  }
}
