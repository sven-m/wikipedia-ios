import Testing
import SwiftData
import Foundation

@MainActor
struct SavedLocationsModelTests {
  
  let container: ModelContainer!
  
  init() throws {
    container = try ModelContainer(for: SavedLocation.self,
                                   configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    container.mainContext.insert(SavedLocation(name: "Test0", latitude: 0, longitude: 0))
    container.mainContext.insert(SavedLocation(name: "Test1", latitude: 1, longitude: 1))
    container.mainContext.insert(SavedLocation(name: "Test2", latitude: 2, longitude: 2))
    try container.mainContext.save()
  }
  
  @Test("Fetch all items in database")
  func fetch() async throws {
    let model = SavedLocationsModel(container: container)
    
    #expect(model.locations.count == 3)
    
    #expect(model.locations[0].name == "Test0")
    #expect(model.locations[0].latitude == 0)
    #expect(model.locations[0].longitude == 0)
    
    #expect(model.locations[1].name == "Test1")
    #expect(model.locations[1].latitude == 1)
    #expect(model.locations[1].longitude == 1)
    
    #expect(model.locations[2].name == "Test2")
    #expect(model.locations[2].latitude == 2)
    #expect(model.locations[2].longitude == 2)
  }
  
  @Test("Delete an item")
  func delete() async throws {
    let model = SavedLocationsModel(container: container)
    
    model.delete(indexSet: [1])
    
    #expect(model.locations.count == 2)
    
    #expect(model.locations[0].name == "Test0")
    #expect(model.locations[0].latitude == 0)
    #expect(model.locations[0].longitude == 0)
    
    #expect(model.locations[1].name == "Test2")
    #expect(model.locations[1].latitude == 2)
    #expect(model.locations[1].longitude == 2)
  }
  
  @Test("Trigger all possible validation errors and then make validation pass")
  func validateDraft() async throws {
    let model = SavedLocationsModel(container: container)
    
    #expect(model.draftLocation == nil)
    #expect(model.validatedDraftLocation == nil)
    
    model.draftNewLocation()
    
    #expect(model.draftLocation != nil)
    #expect(model.validatedDraftLocation == nil)
    #expect(model.validationError == .emptyName)
    
    model.draftLocation?.name = "Test0"
    
    #expect(model.validatedDraftLocation == nil)
    #expect(model.validationError == .duplicateName(
      name: "Test0",
      coordinates: Coordinates(latitude: 0, longitude: 0)
    ))
    
    model.draftLocation?.name = "Test1-duplicate"
    model.draftLocation?.latitude = 1
    model.draftLocation?.longitude = 1
    
    #expect(model.validatedDraftLocation == nil)
    #expect(model.validationError == .duplicateCoordinates(
      name: "Test1",
      coordinates: Coordinates(latitude: 1, longitude: 1)
    ))
    
    model.draftLocation?.name = "Unique"
    model.draftLocation?.latitude = 3
    model.draftLocation?.longitude = 3
    
    #expect(model.validatedDraftLocation != nil)
    #expect(model.validatedDraftLocation == model.draftLocation)
    #expect(model.validationError == nil)
  }
  
  @Test("Save an item and check that it's among the entities now")
  func commit() async throws {
    let model = SavedLocationsModel(container: container)
    
    try #require(model.locations.count == 3)
    
    model.draftNewLocation()
    
    let draftLocation = try #require(model.draftLocation)
    
    draftLocation.name = "Test5"
    draftLocation.latitude = 5
    draftLocation.longitude = 5
    
    let validatedDraftLocation = try #require(model.validatedDraftLocation)
    
    model.commit()
    
    #expect(model.locations.count == 4)
    
    #expect(model.locations[3].name == validatedDraftLocation.name)
    #expect(model.locations[3].latitude == validatedDraftLocation.latitude)
    #expect(model.locations[3].longitude == validatedDraftLocation.longitude)
  }
}
