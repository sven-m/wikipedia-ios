struct Coordinates: Hashable {
  var latitude: Double
  var longitude: Double
}

/// A bit of a contrived protocol to help work with multiple types of objects that define coordinates.
protocol CoordinatesConvertible {
  var coordinates: Coordinates { get }
}

extension Coordinates: CoordinatesConvertible {
  var coordinates: Coordinates { self }
}
