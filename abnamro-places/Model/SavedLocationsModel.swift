import Foundation
import SwiftData

@Observable
class SavedLocationsModel {
  private let container: ModelContainer
  private let context: ModelContext
  
  var entities: [LocationEntity] = []
  var lastError: Error?
  
  var draftLocation: LocationEntity?
  
  init(container: ModelContainer) {
    self.container = container
    let context = ModelContext(container)
    self.context = context
    
    refresh()
  }
  
  func delete(indexSet: IndexSet) {
    for index in indexSet {
      context.delete(entities[index])
    }
    
    refresh()
  }
  
  func refresh() {
    lastError = nil
    do {
      entities = try context.fetch(
        FetchDescriptor<LocationEntity>(sortBy: [.init(\.name)])
      )
    } catch {
      lastError = error
    }
  }
  
  func draftNewLocation() {
    draftLocation = LocationEntity()
  }
  
  func finishDraft() {
    guard let draftLocation,
          draftLocation.isValid else { return }
    
    context.insert(draftLocation)
    self.draftLocation = nil
    
    refresh()
  }
}

@Model
class LocationEntity {
  var name: String
  var latitude: Double
  var longitude: Double
  
  init(name: String = "",
       latitude: Double = 0.0,
       longitude: Double = 0.0) {
    self.name = name
    self.latitude = latitude
    self.longitude = longitude
  }
}

extension LocationEntity {
  var isValid: Bool {
    !name.isEmpty
    && (-90...90).contains(latitude)
    && (-180...180).contains(longitude)
  }
}

extension SavedLocationsModel {
  static func preview() -> SavedLocationsModel {
    let container = try! ModelContainer(
      for: LocationEntity.self,
      configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let context = ModelContext(container)
    context.insert(LocationEntity(name: "Test", latitude: 52, longitude: 4))
    try! context.save()
    
    return SavedLocationsModel(container: container)
  }
}
