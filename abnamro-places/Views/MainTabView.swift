import SwiftUI
import SwiftData

/// The main tab view is responsible for the general view structure, high level error presentation and
/// navigation logic
struct MainTabView: View {
  var apiLocationsModel: APILocationsModel
  var savedLocationsModel: Result<SavedLocationsModel, Error>
  
  @State var isShowingURLNotAcceptedAlert = false
  @State var isShowingMalformedURLAlert = false
  
  @Environment(\.openURL) var openURL
  
  var body: some View {
    TabView {
      APILocationsView(model: apiLocationsModel)
        .tabItem {
          Text("API")
          Image(systemName: "cloud")
        }
      
      savedLocationsTabContent
        .tabItem {
          Text("Saved")
          Image(systemName: "folder")
        }
    }
    .environment(\.openWikipediaWithCoordinates, openURL(coordinates:))
    .alert("Cannot navigate to Wikipedia", isPresented: $isShowingMalformedURLAlert) {
      Button("OK", role: .cancel) {}
    } message: {
      Text("An internal error occurred")
    }
    .alert("Cannot navigate to Wikipedia", isPresented: $isShowingURLNotAcceptedAlert) {
      Button("OK", role: .cancel) {}
    } message: {
      Text("Please check if Wikipedia is installed")
    }
  }
  
  private func openURL(coordinates: Coordinates) {
    guard let url = URL.wikipediaURL(coordinates: coordinates) else {
      isShowingMalformedURLAlert = true
      return
    }
    
    openURL(url) { accepted in
      isShowingURLNotAcceptedAlert = !accepted
    }
  }
  
  @ViewBuilder
  var savedLocationsTabContent: some View {
    switch savedLocationsModel {
    case .success(let model):
      SavedLocationsView(model: model)
    case .failure(let error):
      ContentUnavailableView {
        Label("Failed to Load Saved Locations",
              systemImage: "exclamationmark.octagon.fill")
      } description: {
        Text(error.localizedDescription)
      }
    }
  }
}

#Preview("Regular") {
  @Previewable @State var apiLocationsModel = APILocationsModel.preview()
  @Previewable @State var savedLocationsModel = SavedLocationsModel.preview()
  
  MainTabView(
    apiLocationsModel: apiLocationsModel,
    savedLocationsModel: .success(savedLocationsModel)
  )
}

#Preview("Errors") {
  @Previewable @State var apiLocationsModel = APILocationsModel.preview()
  
  MainTabView(
    apiLocationsModel: apiLocationsModel,
    savedLocationsModel: .failure(NSError(domain: "preview", code: -1)),
    isShowingURLNotAcceptedAlert: true
  )
}
