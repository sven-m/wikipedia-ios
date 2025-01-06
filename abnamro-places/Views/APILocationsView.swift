import SwiftUI


struct APILocationsView: View {
  var model: APILocationsModel
  
  var body: some View {
    NavigationStack {
      List {
        Section {
          ForEach(model.locations ?? [], id: \.self) { location in
            LocationRowView(name: location.name, coordinates: location.coordinates)
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
