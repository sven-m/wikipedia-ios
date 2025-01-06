struct Coordinates: Hashable {
  var latitude: Double
  var longitude: Double
}

protocol CoordinatesConvertible {
  var coordinates: Coordinates { get }
}

extension Coordinates: CoordinatesConvertible {
  var coordinates: Coordinates { self }
}
