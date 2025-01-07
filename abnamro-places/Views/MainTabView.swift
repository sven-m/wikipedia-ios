import SwiftUI
import SwiftData

struct MainTabView: View {
  var apiLocationsModel: APILocationsModel
  var savedLocationsModel: Result<SavedLocationsModel, Error>
  
  @State var isShowingURLErrorAlert = false
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
    .alert("Cannot navigate to Wikipedia", isPresented: $isShowingURLErrorAlert) {
      Button("OK", role: .cancel) {}
    } message: {
      Text("An unknown error occurred")
    }
  }
  
  private func openURL(coordinates: Coordinates) {
    guard let url = URL.wikipediaURL(coordinates: coordinates) else {
      isShowingURLErrorAlert = true
      return
    }
    
    openURL(url)
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
    isShowingURLErrorAlert: true
  )
}
