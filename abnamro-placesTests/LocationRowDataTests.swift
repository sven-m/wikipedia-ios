import Foundation
import Testing

/// A bit contrived, maybe, but this is how we could test transformations from model to view data
struct LocationRowDataTests {
  let locale = Locale(identifier: "en_US_POSIX")
  
  @Test("The title gets generated properly")
  func title() async throws {
    let rowData = LocationRowData(
      name: "Randstad",
      coordinates: Coordinates(latitude: 52, longitude: 4.5),
      locale: locale
    )
    
    #expect(rowData.title == "Randstad")
  }
  
  @Test("The subtitle gets generated properly, using standard locale")
  func subtitle() async throws {
    let rowData = LocationRowData(
      name: "Randstad",
      coordinates: Coordinates(latitude: 52, longitude: 4.5),
      locale: locale
    )
    
    #expect(rowData.subtitle == "Lat: 52.0000000, Long: 4.5000000")
  }
}
