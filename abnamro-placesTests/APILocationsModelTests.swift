import Foundation
import Testing

@MainActor
struct APILocationsModelTests {
  
  @Test("Any duplicates in the API response are filtered out")
  func deduplication() async throws {
    let model = APILocationsModel {
      [
        APILocation(name: "Test", latitude: 1, longitude: 2),
        APILocation(name: "Test", latitude: 1, longitude: 2),
      ]
    }
    
    await model.refresh()
    
    #expect(model.locations == [APILocation(name: "Test", latitude: 1, longitude: 2)])
  }
  
  @Test("Errors are propagated")
  func errors() async throws {
    let error = NSError(domain: "test", code: -10)
    
    let model = APILocationsModel {
      throw error
    }
    
    await #expect(throws: error) {
      try await model.fetch()
    }
  }
  
}
