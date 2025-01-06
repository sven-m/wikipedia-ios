import Foundation
import SwiftData

enum SavedLocationValidationError: LocalizedError {
  case noDraft
  case duplicateName(name: String, coordinates: Coordinates)
  case duplicateCoordinates(name: String, coordinates: Coordinates)
  case emptyName
  
  var errorDescription: String? {
    switch self {
    case .noDraft:
      String(localized: "Cannot create a location")
    case .duplicateName(let name, let coordinates):
      String(localized: "A location with name \"\(name)\" already exists (coordinates: \(coordinates.latitude),\(coordinates.longitude)")
    case .duplicateCoordinates(let name, let coordinates):
      String(localized: "A location with coordinates \(coordinates.latitude),\(coordinates.longitude) already exists (name: \(name)")
    case .emptyName:
      String(localized: "Enter a name to save")
    }
  }
}

@MainActor
@Observable
class SavedLocationsModel {
  private let container: ModelContainer
  
  var entities: [SavedLocation] = []
  var lastError: Error?
  
  var draftLocation: SavedLocation?
  
  var validatedDraftLocation: SavedLocation? {
    do {
      try validate()
      
      return draftLocation
    } catch {
      return nil
    }
  }
  
  var validationError: SavedLocationValidationError? {
    do {
      try validate ()
      return nil
    } catch {
      return error
    }
  }
  
  init(container: ModelContainer) {
    self.container = container
    
    refresh()
  }
  
  func delete(indexSet: IndexSet) {
    for index in indexSet {
      container.mainContext.delete(entities[index])
    }
    
    refresh()
  }
  
  func refresh() {
    lastError = nil
    do {
      entities = try container.mainContext.fetch(
        FetchDescriptor<SavedLocation>(sortBy: [.init(\.name)])
      )
    } catch {
      lastError = error
    }
  }
  
  func draftNewLocation() {
    draftLocation = SavedLocation()
  }
  
  func validate() throws (SavedLocationValidationError) {
    guard let draftLocation else {
      throw .noDraft
    }
    
    guard !draftLocation.name.isEmpty else {
      throw .emptyName
    }
    
    let groupedByName = Dictionary(grouping: entities, by: \.name)
    if let duplicated = groupedByName[draftLocation.name]?.first {
      throw .duplicateName(name: duplicated.name,
                           coordinates: duplicated.coordinates)
    }
    
    let groupedByCoordinates = Dictionary(grouping: entities, by: \.coordinates)
    if let duplicated = groupedByCoordinates[draftLocation.coordinates]?.first {
      throw .duplicateCoordinates(name: duplicated.name,
                                  coordinates: duplicated.coordinates)
    }
  }
  
  func commit() {
    guard let validatedDraftLocation else { return }
    
    do {
      container.mainContext.insert(validatedDraftLocation)
      self.draftLocation = nil
      
      try container.mainContext.save()
      refresh()
    } catch {
      lastError = error
    }
  }
}



extension SavedLocationsModel {
  static func preview() -> SavedLocationsModel {
    let container = try! ModelContainer(
      for: SavedLocation.self,
      configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let context = ModelContext(container)
    context.insert(SavedLocation(name: "Test", latitude: 52, longitude: 4))
    try! context.save()
    
    return SavedLocationsModel(container: container)
  }
}
