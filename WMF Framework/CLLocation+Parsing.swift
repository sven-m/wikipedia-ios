private let locale = Locale(identifier: "en_US_POSIX")

@objc extension CLLocation {
  convenience init?(commaSeparatedString string: String) {
    let components = string.split(separator: ",")
    let formatStyle = FloatingPointFormatStyle<Double>().locale(locale)
    
    guard components.count == 2,
          let latitude = try? formatStyle.parseStrategy.parse(String(components[0])),
          let longitude = try? formatStyle.parseStrategy.parse(String(components[1])) else {
      return nil
    }
    
    self.init(latitude: latitude, longitude: longitude)
  }
}
