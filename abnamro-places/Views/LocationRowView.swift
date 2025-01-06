import SwiftUI

struct LocationRowView: View {
  var name: String?
  var latitude: Double
  var longitude: Double
  
  var body: some View {
    Button {
      openURL(latitude: latitude, longitude: longitude)
    } label: {
      Label {
        let rowData = LocationRowData(name: name,
                                      latitude: latitude,
                                      longitude: longitude)
        
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
  
  private func openURL(latitude: Double, longitude: Double) {
    if let url = URL.wikipediaURL(latitude: latitude,
                                  longitude: longitude) {
      UIApplication.shared.open(url)
    }
  }
}

struct LocationRowData {
  var title: String
  var subtitle: String
  
  init(name: String?, latitude: Double, longitude: Double) {
    self.title = name ?? String(localized: "(untitled)")
    self.subtitle = String(localized: "Lat: \(latitude, format: .number.precision(.fractionLength(7))), Long: \(longitude, format: .number.precision(.fractionLength(7)))")
  }
}



#Preview {
  List {
    LocationRowView(name: "Test", latitude: 52, longitude: 4)
  }
}
