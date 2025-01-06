import Testing
@testable import abnamro_places

@MainActor
struct APILocationsModelTests {
  
  @Test func deduplication() async throws {
    let model = APILocationsModel {
      [
        APILocation(name: "Test", latitude: 1, longitude: 2),
        APILocation(name: "Test", latitude: 1, longitude: 2),
      ]
    }
    
    await model.refresh()
    
    #expect(model.locations == [APILocation(name: "Test", latitude: 1, longitude: 2)])
  }
  
}
