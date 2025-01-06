import SwiftUI


struct APILocationsView: View {
  var model: APILocationsModel
  
  var body: some View {
    NavigationStack {
      List {
        Section {
          ForEach(model.locations ?? [], id: \.self) { location in
            row(location: location)
          }
        } footer: {
          if model.locations != nil {
            Text("Tap a location to open it in the Wikipedia app")
          }
        }
      }
      .scrollDisabled(model.locations == nil)
      .overlay {
        contentUnavailableView
      }
     
      .task {
        await model.refresh()
      }
      .refreshable {
        await model.refresh()
      }
      
      .toolbar {
        ToolbarItem(placement: .primaryAction) {
          Button {
            Task { await model.refresh() }
          } label: {
            Image(systemName: "arrow.clockwise")
          }
        }
      }
      .navigationTitle("Locations (API)")
    }
  }
  
  @ViewBuilder
  private func row(location: Location) -> some View {
    Button {
      openURL(location: location)
    } label: {
      Label {
        let rowData = LocationRowData(location: location)
        
        VStack(alignment: .leading) {
          Text(rowData.title)
          Text(rowData.subtitle)
            .font(.caption)
            .foregroundStyle(.secondary)
          
        }
        .tint(.primary)
      } icon: {
        Image(systemName: "mappin.circle")
      }
    }
  }
  
  private func openURL(location: Location) {
    if let url = URL.wikipediaURL(latitude: location.latitude,
                                  longitude: location.longitude) {
      UIApplication.shared.open(url)
    }
  }
  
  @ViewBuilder
  private var contentUnavailableView: some View {
    if let error = model.error {
      ContentUnavailableView {
        Label("Fetching Locations Failed", systemImage: "exclamationmark.triangle.fill")
      } description: {
        Text(verbatim: error.localizedDescription)
      } actions: {
        Button("Retry") {
          Task {
            await model.refresh()
          }
        }
      }
    } else if model.locations == nil {
      ContentUnavailableView {
        ProgressView()
      } description: {
        Text("Loading Locations")
         
      }
    }
  }
}

struct LocationRowData {
  var title: String
  var subtitle: String
  
  init(location: Location) {
    self.title = location.name ?? String(localized: "(untitled)")
    self.subtitle = String(localized: "Lat: \(location.latitude, format: .number.precision(.fractionLength(7))), Long: \(location.longitude, format: .number.precision(.fractionLength(7)))")
  }
}

#Preview("Regular Response") {
  @Previewable @State var model = APILocationsModel.preview()
  APILocationsView(model: model)
}

#Preview("Error Response") {
  @Previewable @State var errorModel = APILocationsModel {
    throw LocationsFetchError.response(nil)
  }
  
  APILocationsView(model: errorModel)
}
