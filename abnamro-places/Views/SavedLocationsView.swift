import SwiftUI

struct SavedLocationsView: View {
  var body: some View {
    NavigationStack {
      List {
        
      }
      .scrollDisabled(true)
      .overlay {
        ContentUnavailableView {
          Label("No Saved Locations", systemImage: "mappin.and.ellipse.circle.fill")
        } description: {
          Text("You have not saved a location yet")
        } actions: {
          Button("Add New Saved Location") {}
        }
      }
      .navigationTitle("Locations (Saved)")
    }
  }
}

#Preview {
  SavedLocationsView()
}
