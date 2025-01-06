import SwiftUI
import MapKit

let defaultCoordinates = (latitude: 52.0, longitude: 4.5)

struct AddNewSavedLocationView: View {
  @Bindable var draft: LocationEntity
  var insert: () -> Void
  
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
          Map(position: $position, interactionModes: [.pan, .zoom])
            .onMapCameraChange(frequency: .continuous) { mapCameraUpdateContext in
              draft.latitude = mapCameraUpdateContext.region.center.latitude
              draft.longitude = mapCameraUpdateContext.region.center.longitude
            }
            .mapControls {
              MapUserLocationButton()
            }
            .aspectRatio(1, contentMode: .fit)
            .listRowInsets(.init())
          
          HStack {
            Text("Latitude")
            Spacer()
            Text(draft.latitude, format: .number)
              .foregroundStyle(.secondary)
          }
          
          HStack {
            Text("Longitude")
            Spacer()
            Text(draft.longitude, format: .number)
              .foregroundStyle(.secondary)
          }
        }
        
        Section {
          Button("Save") {
            insert()
          }
          .disabled(!draft.isValid)
        }
      }
      .navigationTitle("Add New Location")
      .navigationBarTitleDisplayMode(.inline)
    }
  }
}

#Preview {
  @Previewable @State var model = {
    let model = SavedLocationsModel.preview()
    model.draftLocation = LocationEntity()
    return model
  }()
  
  AddNewSavedLocationView(draft: model.draftLocation!, insert: {})
}
