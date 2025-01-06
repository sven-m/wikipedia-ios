import Foundation
import SwiftData

@Observable
class SavedLocationsModel {
  private let container: ModelContainer
  private let context: ModelContext
  
  var entities: [LocationEntity]?
  var lastError: Error?
  
  init(container: ModelContainer) {
    self.container = container
    let context = ModelContext(container)
    self.context = context
    
    refresh()
  }
  
  func delete(indexSet: IndexSet) {
    guard let entities else { return }
    
    for index in indexSet {
      context.delete(entities[index])
    }
    
    refresh()
  }
  
  private func refresh() {
    do {
      entities = try context.fetch(FetchDescriptor<LocationEntity>())
    } catch {
      lastError = error
    }
  }
}

@Model
class LocationEntity {
  var name: String
  var latitude: Double
  var longitude: Double
  
  init(name: String, latitude: Double, longitude: Double) {
    self.name = name
    self.latitude = latitude
    self.longitude = longitude
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
    
    let model = SavedLocationsModel(container: container)
    return model
  }
}
