import Foundation
import Testing

struct WikipediaURLTests {
  
  @Test("Coordinates with integer values result in a wellformed URL")
  func integers() async throws {
    let url = URL.wikipediaURL(coordinates: Coordinates(latitude: 1, longitude: 2))
    
    #expect(url == URL(string: "wikipedia://places?WMFPlacesLatLong=1,2"))
  }
  
  @Test("Coordinates with non-integer values result in a wellformed URL")
  func decimals() async throws {
    let url = URL.wikipediaURL(coordinates: Coordinates(latitude: 1.23456, longitude: 2.344567))
    
    #expect(url == URL(string: "wikipedia://places?WMFPlacesLatLong=1.23456,2.34567"))
  }
  
}
