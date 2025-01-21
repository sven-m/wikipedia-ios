/// Structure for facilitating passing around lat/longs everywhere
struct Coordinates: Hashable {
  var latitude: Double
  var longitude: Double
}

/// A bit of a contrived protocol to help work with multiple types that contain coordinates.
protocol CoordinatesConvertible {
  var coordinates: Coordinates { get }
}

extension Coordinates: CoordinatesConvertible {
  var coordinates: Coordinates { self }
}
