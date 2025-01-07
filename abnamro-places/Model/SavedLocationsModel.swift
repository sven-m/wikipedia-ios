import Foundation
import SwiftData

/// A model that represents the collection of `SavedLocation` entities stored on the device
@MainActor
@Observable
class SavedLocationsModel {
  private let container: ModelContainer
  
  
  /// All locations currently stored on the device
  var locations: [SavedLocation] = []
  
  /// The last error thrown, such as fetch or save errors
  var lastError: Error?
  
  /// Contains the location currently being drafted, if any, otherwise `nil`
  var draftLocation: SavedLocation?
  
  /// Returns the value of `draftLocation` if all its properties have valid values, otherwise `nil`
  var validatedDraftLocation: SavedLocation? {
    do {
      try validate()
      
      return draftLocation
    } catch {
      return nil
    }
  }
  
  /// Returns any validation errors, or none if the item being drafted is valid, or if there is nothing being drafted.
  var validationError: SavedLocationValidationError? {
    do {
      try validate ()
      return nil
    } catch {
      return error
    }
  }
  
  /// Create a new model and fetch items immediately
  /// - Parameter container: a model container for the `SavedLocation` entity type
  init(container: ModelContainer) {
    self.container = container
    
    refresh()
  }
  
  /// Delete items at the indices in the `locations` array, specified by the given `IndexSet`
  ///
  /// - Deleting an item refreshes the `locations` array immediately.
  /// - Specifying indices out of bound of the array will cause a fatal error
  ///
  /// - Parameter indexSet: the indices of the items to delete
  func delete(indexSet: IndexSet) {
    for index in indexSet {
      container.mainContext.delete(locations[index])
    }
    
    refresh()
  }
  
  /// Reload the `locations` array.
  ///
  /// Used to populate the array after creating the model to recovery from previously thrown errors
  func refresh() {
    lastError = nil
    do {
      locations = try container.mainContext.fetch(
        FetchDescriptor<SavedLocation>(sortBy: [.init(\.name)])
      )
    } catch {
      lastError = error
    }
  }
  
  /// Start drafting a new location, used by `AddNewLocationView`
  func draftNewLocation() {
    draftLocation = SavedLocation()
  }
  
  private func validate() throws (SavedLocationValidationError) {
    /// Rationale: there's no harm in calling `commit()` when there's nothing to validate, so no need to throw an error here
    guard let draftLocation else {
      return
    }
    
    guard !draftLocation.name.isEmpty else {
      throw .emptyName
    }
    
    let groupedByName = Dictionary(grouping: locations, by: \.name)
    if let duplicated = groupedByName[draftLocation.name]?.first {
      throw .duplicateName(name: duplicated.name,
                           coordinates: duplicated.coordinates)
    }
    
    let groupedByCoordinates = Dictionary(grouping: locations, by: \.coordinates)
    if let duplicated = groupedByCoordinates[draftLocation.coordinates]?.first {
      throw .duplicateCoordinates(name: duplicated.name,
                                  coordinates: duplicated.coordinates)
    }
  }
  
  /// Save the item in `draftLocation` to the model context and refresh the list.
  ///
  /// If no valid draft exists, this method does nothing.
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

enum SavedLocationValidationError: LocalizedError, Equatable {
  case duplicateName(name: String, coordinates: Coordinates)
  case duplicateCoordinates(name: String, coordinates: Coordinates)
  case emptyName
  
  var errorDescription: String? {
    switch self {
    case .duplicateName(let name, let coordinates):
      String(localized: "A location with name \"\(name)\" already exists (coordinates: \(coordinates.latitude),\(coordinates.longitude)")
    case .duplicateCoordinates(let name, let coordinates):
      String(localized: "A location with coordinates \(coordinates.latitude),\(coordinates.longitude) already exists (name: \(name)")
    case .emptyName:
      String(localized: "Enter a name to save")
    }
  }
}

extension SavedLocationsModel {
  /// Creates an instance of the model that is given an in-memory Swift Data container, which is useful for
  /// unit tests and SwiftUI previews.
  /// - Returns: a model instance with an in-memory Swift Data container with a single entity.
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
