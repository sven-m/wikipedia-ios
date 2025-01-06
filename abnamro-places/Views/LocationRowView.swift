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
  
  init(name: String?, coordinates: Coordinates, locale: Locale = .autoupdatingCurrent) {
    let latitudeString = coordinates.latitude.formatted(.number.precision(.fractionLength(7)).locale(locale))
    let longitudeString = coordinates.longitude.formatted(.number.precision(.fractionLength(7)).locale(locale))
    
    self.title = name ?? String(localized: "(untitled)")
    self.subtitle = String(localized: "Lat: \(latitudeString), Long: \(longitudeString)")
  }
}



#Preview {
  List {
    LocationRowView(name: "Test", coordinates: Coordinates(latitude: 52, longitude: 4))
  }
}
