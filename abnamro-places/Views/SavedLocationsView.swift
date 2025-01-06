import SwiftUI
import SwiftData

struct SavedLocationsView: View {
  @Bindable var model: SavedLocationsModel
  
  var body: some View {
    NavigationStack {
      List {
        Section {
          ForEach(model.entities ?? []) { entity in
            
            LocationRowView(name: entity.name,
                            latitude: entity.latitude,
                            longitude: entity.longitude)
          }
          .onDelete { indexSet in
            model.delete(indexSet: indexSet)
          }
        } footer: {
          if model.entities?.isEmpty == false {
            Text("Swipe left to delete locations")
          }
        }
        
        if model.entities?.isEmpty == false {
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
      .scrollDisabled(true)
      .overlay {
        if let lastError = model.lastError {
          failureView(error: lastError)
        } else if model.entities?.isEmpty == true {
          noSavedLocationsView
        }
      }
      .sheet(item: $model.draftLocation) { draft in
        AddNewSavedLocationView(draft: draft) {
          model.finishDraft()
        }
      }
      .navigationTitle("Locations (Saved)")
    }
  }
  
  func failureView(error: Error) -> some View {
    ContentUnavailableView {
      Label("Failed to Load Saved Locations",
            systemImage: "exclamationmark.octagon.fill")
    } description: {
      Text(error.localizedDescription)
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

#Preview {
  @Previewable @State var model = SavedLocationsModel.preview()
  
  SavedLocationsView(model: model)
}
