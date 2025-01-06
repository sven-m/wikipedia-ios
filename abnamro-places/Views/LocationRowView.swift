import SwiftUI

struct LocationRowView: View  {
  var name: String?
  var coordinates: Coordinates
  
  var body: some View {
    Button {
      openURL()
    } label: {
      Label {
        let rowData = LocationRowData(name: name, coordinates: coordinates)
        
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
  
  private func openURL() {
    if let url = URL.wikipediaURL(coordinates: coordinates) {
      UIApplication.shared.open(url)
    }
  }
}

struct LocationRowData {
  var title: String
  var subtitle: String
  
  init(name: String?, coordinates: Coordinates) {
    self.title = name ?? String(localized: "(untitled)")
    self.subtitle = String(localized: "Lat: \(coordinates.latitude, format: .number.precision(.fractionLength(7))), Long: \(coordinates.longitude, format: .number.precision(.fractionLength(7)))")
  }
}



#Preview {
  List {
    LocationRowView(name: "Test", coordinates: Coordinates(latitude: 52, longitude: 4))
  }
}
