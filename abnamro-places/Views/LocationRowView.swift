import SwiftUI

struct LocationRowView: View  {
  var name: String?
  var coordinates: Coordinates
  @Environment(\.openWikipediaWithCoordinates) var openWikipediaWithCoordinates
  
  var body: some View {
    Button {
      openWikipediaWithCoordinates(coordinates)
    } label: {
      Label {
        let rowData = LocationRowData(name: name, coordinates: coordinates)
        
        VStack(alignment: .leading) {
          Text(rowData.title)
          Text(rowData.subtitle)
            .font(.caption)
            .foregroundStyle(.secondary)
            .accessibilityIdentifier("Coordinates")
          
        }
        .tint(.primary)
      } icon: {
        Image(systemName: "mappin.circle")
      }
    }
  }
}

#Preview {
  List {
    LocationRowView(name: "Test", coordinates: Coordinates(latitude: 52, longitude: 4))
  }
}
