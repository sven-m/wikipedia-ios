import Foundation
import Testing

struct WikipediaURLTests {
  
  @Test
  func simpleURL() async throws {
    let url = URL.wikipediaURL(coordinates: Coordinates(latitude: 1, longitude: 2))
    
    #expect(url == URL(string: "wikipedia://places?WMFPlacesLatLong=1.0,2.0"))
  }
  
}
