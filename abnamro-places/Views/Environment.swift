import SwiftUI

extension EnvironmentValues {
  /// This environment entry allows decoupling of location list rows and navigation logic
  @Entry var openWikipediaWithCoordinates: (Coordinates) -> Void = { _ in }
}
