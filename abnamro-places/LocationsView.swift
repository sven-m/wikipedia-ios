import SwiftUI

struct LocationsView: View {
  let hardcoded: URL! = URL(string: "https://en.wikipedia.org/wiki/places/1,2")
  
    var body: some View {
      Link("Hardcoded Location", destination: hardcoded)
    }
}

#Preview {
  LocationsView()
}
