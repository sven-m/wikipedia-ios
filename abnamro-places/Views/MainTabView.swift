import SwiftUI
import SwiftData

struct MainTabView: View {
  @State var apiLocationsModel = APILocationsModel(fetch: fetchAPILocations)
  
  var body: some View {
    TabView {
      APILocationsView(model: apiLocationsModel)
        .tabItem {
          Text("API")
          Image(systemName: "cloud")
        }
      
      SavedLocationsView()
        .tabItem {
          Text("Saved")
          Image(systemName: "folder")
        }
    }
  }
}

#Preview {
  @Previewable @State var apiLocationsModel = APILocationsModel.preview()
  
  MainTabView(apiLocationsModel: apiLocationsModel)
}
