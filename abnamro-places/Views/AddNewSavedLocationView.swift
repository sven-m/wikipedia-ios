import SwiftUI
import MapKit

let defaultCoordinates = (latitude: 52.0, longitude: 4.5)

struct AddNewSavedLocationView: View {
  @Bindable var draft: SavedLocation
  var model: SavedLocationsModel
  
  @State var position = MapCameraPosition.region(
    MKCoordinateRegion(
      center: CLLocationCoordinate2D(
        latitude: defaultCoordinates.latitude,
        longitude: defaultCoordinates.longitude
      ),
      span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
    )
  )
  
  var body: some View {
    NavigationStack {
      Form {
        Section {
          TextField("Name", text: $draft.name)
            .textInputAutocapitalization(.words)
        } footer: {
          Text("Required")
        }
        
        Section {
          Map(position: $position, interactionModes: [.pan, .zoom]) {
            ForEach(model.locations) { entity in
              Marker(
                entity.name,
                coordinate: CLLocationCoordinate2DMake(entity.latitude,
                                                       entity.longitude))
            }
          }
            .onMapCameraChange(frequency: .continuous) { mapCameraUpdateContext in
              draft.latitude = mapCameraUpdateContext.region.center.latitude
              draft.longitude = mapCameraUpdateContext.region.center.longitude
            }
            .aspectRatio(1, contentMode: .fit)
            .listRowInsets(.init())
          
          HStack {
            Text("Latitude")
            Spacer()
            Text(draft.latitude, format: .number)
              .foregroundStyle(.secondary)
              .accessibilityIdentifier("Latitude Value")
          }
          
          HStack {
            Text("Longitude")
            Spacer()
            Text(draft.longitude, format: .number)
              .foregroundStyle(.secondary)
              .accessibilityIdentifier("Longitude Value")
          }
        }
        
        Section {
          Button("Save") {
            model.commit()
          }
          .disabled(model.validatedDraftLocation == nil)
        } footer: {
          if let error = model.validationError {
            Text(verbatim: error.localizedDescription)
          }
        }
      }
      .navigationTitle("Add New Location")
      
      /// Having a MapKit map in the Form makes the `.largeTitle` mode
      /// give weird results, so let's make it `.inline` to save some time
      .navigationBarTitleDisplayMode(.inline)
    }
  }
}

#Preview {
  @Previewable @State var model = {
    let model = SavedLocationsModel.preview()
    model.draftLocation = SavedLocation()
    return model
  }()
  
  if let draftLocation = model.draftLocation {
    AddNewSavedLocationView(draft: draftLocation,
                            model: model)
  } else {
    // Put a new draft in the model, to start editing a new one
    Button("New") {
      model.draftLocation = SavedLocation()
    }
    
    // Replace model, discarding previously saved items
    Button("Reset") {
      model = SavedLocationsModel.preview()
      model.draftLocation = SavedLocation()
    }
  }
}
