import Foundation

/// A function that produces `APILocation` objects, as fetched from the server
func fetchAPILocations() async throws (LocationsFetchError) -> [APILocation] {
  let (data, response): (Data, URLResponse)
  do {
    (data, response) = try await URLSession.shared.data(from: .api)
  } catch {
    throw .network(error)
  }
  
  let httpResponse = response as? HTTPURLResponse
  
  guard httpResponse?.statusCode == 200 else {
    throw .response(httpResponse)
  }
  
  do {
    return try JSONDecoder().decode(LocationsResponse.self, from: data).locations
  } catch {
    throw .decode(error)
  }
}

enum LocationsFetchError: LocalizedError {
  case network(Error)
  case response(HTTPURLResponse?)
  case decode(Error)
  
  var errorDescription: String? {
    switch self {
    case .network(let networkError):
      return String(localized: "Network error: \(networkError.localizedDescription)")
      
    case .response(let response?):
      return String(localized: "Server responded with error: \(response.statusCode), \(response.description)")
      
    case .response:
      return String(localized: "Server responded with unknown response")
      
    case .decode(let decodingError):
      return String(localized: "Server responded with invalid locations: \(decodingError.localizedDescription)")
    }
  }
}

