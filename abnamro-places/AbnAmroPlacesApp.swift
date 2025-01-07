import SwiftUI
import SwiftData

@main
struct AbnAmroPlacesApp: App {
  @State var apiLocationsModel = APILocationsModel(fetch: fetchAPILocations)
  @State var savedLocationsModel = Result {
    try SavedLocationsModel(container: ModelContainer(for: SavedLocation.self))
  }
  
  var body: some Scene {
    WindowGroup {
      MainTabView(
        apiLocationsModel: apiLocationsModel,
        savedLocationsModel: savedLocationsModel
      )
      
    }
  }
}
