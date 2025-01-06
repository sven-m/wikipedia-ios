import SwiftUI
import SwiftData

struct SavedLocationsView: View {
  @Bindable var model: SavedLocationsModel
  
  var body: some View {
    NavigationStack {
      List {
        Section {
          ForEach(model.locations) { entity in
            LocationRowView(name: entity.name, coordinates: entity.coordinates)
          }
          .onDelete { indexSet in
            model.delete(indexSet: indexSet)
          }
        } footer: {
          if !model.locations.isEmpty {
            Text("Swipe left to delete locations")
          }
        }
        
        if !model.locations.isEmpty {
          Button {
            model.draftNewLocation()
          } label: {
            Label {
              Text("Add New Saved Location")
            } icon: {
              Image(systemName: "plus.circle.fill")
                .foregroundStyle(.green)
            }
          }
        }
      }
      .scrollDisabled(model.locations.isEmpty)
      .overlay {
        if let lastError = model.lastError {
          failureView(error: lastError)
        } else if model.locations.isEmpty {
          noSavedLocationsView
        }
      }
      .sheet(item: $model.draftLocation) { draft in
        AddNewSavedLocationView(draft: draft, model: model)
      }
      .navigationTitle("Locations (Saved)")
    }
  }
  
  func failureView(error: Error) -> some View {
    ContentUnavailableView {
      Label("Error Occurred",
            systemImage: "exclamationmark.octagon.fill")
    } description: {
      Text(error.localizedDescription)
    } actions: {
      Button("Reload") {
        model.refresh()
      }
    }
  }
  
  var noSavedLocationsView: some View {
    ContentUnavailableView {
      Label("No Saved Locations", systemImage: "mappin.and.ellipse.circle.fill")
    } description: {
      Text("You have not saved a location yet")
    } actions: {
      Button("Add New Saved Location") {
        model.draftNewLocation()
      }
    }
  }
}

#Preview("Regular") {
  @Previewable @State var model = SavedLocationsModel.preview()
  
  SavedLocationsView(model: model)
}

#Preview("Error") {
  @Previewable @State var model = {
    let model = SavedLocationsModel.preview()
    model.locations = []
    model.lastError = NSError(domain: "preview", code: -1)
    return model
  }()
  
  SavedLocationsView(model: model)
}
