import XCTest

final class AbnAmroPlacesUITests: XCTestCase {
  @MainActor
  let wikipediaApp = XCUIApplication(bundleIdentifier: "org.wikimedia.wikipedia")
  
  @MainActor
  let placesApp = XCUIApplication()
  
  @MainActor
  let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
  
  override func setUpWithError() throws {
    continueAfterFailure = false
  }
  
  override func tearDownWithError() throws {
  }
  
  /// Tests whether the Wikipedia app can be launched with a URL
  @MainActor
  func testLaunchWikipediaWithURLFromNotRunning() throws (TestError) {
    wikipediaApp.activate()
    normalizeWikipediaUIState()
    wikipediaApp.terminate()
    
    let launchURL = URL.wikipediaURL(
      coordinates: Coordinates(latitude: 52, longitude: 4.5)
    )!
    
    XCUIDevice.shared.system.open(launchURL)
    
    guard wikipediaApp.wait(for: .runningForeground, timeout: 1) else {
      throw .wikipediaAppDidNotLaunch
    }
    
    waitForMapViewCoordinatesInWikipedia(latitude: 52, longitude: 4.5)
  }
  
  /// Tests whether the Wikipedia app can be brought to the foreground with a URL
  @MainActor
  func testLaunchWikipediaWithURLFromBackground() throws (TestError) {
    wikipediaApp.launch()
    normalizeWikipediaUIState()
    springboard.activate()
    
    let launchURL = URL.wikipediaURL(
      coordinates: Coordinates(latitude: 52, longitude: 4.5)
    )!
    
    XCUIDevice.shared.system.open(launchURL)
    
    guard wikipediaApp.wait(for: .runningForeground, timeout: 1) else {
      throw .wikipediaAppDidNotLaunch
    }
    
    waitForMapViewCoordinatesInWikipedia(latitude: 52, longitude: 4.5)
  }
  
  /// Tests whether the Wikipedia app can be direct to show the map while already in foreground with a URL
  @MainActor
  func testLaunchWikipediaWithURLInForeground() throws (TestError) {
    wikipediaApp.activate()
    normalizeWikipediaUIState()
    
    let launchURL = URL.wikipediaURL(
      coordinates: Coordinates(latitude: 52, longitude: 4.5)
    )!
    
    XCUIDevice.shared.system.open(launchURL)
    
    guard wikipediaApp.wait(for: .runningForeground, timeout: 1) else {
      throw .wikipediaAppDidNotLaunch
    }
    
    waitForMapViewCoordinatesInWikipedia(latitude: 52, longitude: 4.5)
  }
  
  /// A helper structure that obtains the lat/long values from the MapKit map in the WIkipedia app,
  /// which specifically has behavior implemented to encode the center coordinate in the map view's
  /// accessibility value as a string
  @MainActor
  struct MapViewAccessibilityValue {
    var latitude: Double
    var longitude: Double
    
    init?(mapView: XCUIElement) {
      guard let mapViewValue = mapView.value as? String else {
        return nil
      }
      
      let mapViewCoordinateComponents = mapViewValue.split(separator: ",")
      
      guard mapViewCoordinateComponents.count == 2,
            let latitude = Double(mapViewCoordinateComponents[0]),
            let longitude = Double(mapViewCoordinateComponents[1])
      else {
        return nil
      }
      
      self.latitude = latitude
      self.longitude = longitude
    }
  }
  
  /// Tests whether we can delete (if needed), create and use a custom location
  @MainActor
  func testCustomLocationAndNavigationToWikipedia() throws {
    removeAppIfNeeded(title: "Wikipedia")
    wikipediaApp.activate()
    
    normalizeWikipediaUIState()
        
    placesApp.launch()
    let coordinates = try createCustomLocationInPlacesApp()
    
    placesApp.staticTexts["My Test Location"].tap()
    XCTAssertTrue(wikipediaApp.wait(for: .runningForeground, timeout: 10))
    
    waitForMapViewCoordinatesInWikipedia(
      latitude: coordinates.latitude,
      longitude: coordinates.longitude
    )
  }
  
  /// Tests whether the app shows an error alert when the Wikipedia app is not installed
  @MainActor
  func testCustomLocationAndFailedNavigationToWikipedia() throws {
    removeAppIfNeeded(title: "Wikipedia")
    
    placesApp.launch()
    _ = try createCustomLocationInPlacesApp()
    
    placesApp.staticTexts["My Test Location"].tap()
    
    XCTAssert(placesApp.staticTexts["Cannot navigate to Wikipedia"].waitForExistence(timeout: 1))
  }
  
  @MainActor
  private func normalizeWikipediaUIState() {
    // If Wikipedia is launched for the first time, we need to skip this intro
    // dialog
    let introSkipButton = wikipediaApp.buttons["Skip"]
    if introSkipButton.waitForExistence(timeout: 1) {
      introSkipButton.tap()
    }
    
    // If Wikipedia is launched for the first time, we need to give it location
    // permission in order to properly use the map
    wikipediaApp.tabBars.buttons["Places"].tap()
    let enableLocationButton = wikipediaApp.buttons["Enable location"]
    if enableLocationButton.waitForExistence(timeout: 1) {
      enableLocationButton.tap()
    }
    
    // The recommended way is to use add addUIInterruptionMonitor(), but it
    // works in the background, and we want to wait for the dialog to be
    // handled, which, if done with expectations, can cause deadlock in our test.
    // so let's do it the dirty way.
    let locationPermissionDialog = springboard.alerts.buttons["Allow While Using App"]
    if locationPermissionDialog.waitForExistence(timeout: 2) {
      locationPermissionDialog.tap()
    }
    
    // let's move the map view a bit to the left, to ensure we do not have the
    //location from previous test still in view
    wikipediaApp.otherElements["Map view"].swipeLeft(velocity: .fast)
    
    // let's exit the places tab to ensure it is navigated to
    wikipediaApp.tabBars.buttons["Explore"].tap()
  }
  
  
  /// Creates a new saved location in the Places app.
  /// 
  /// - Returns: the coordinates of the location that ended up being created
  @MainActor
  private func createCustomLocationInPlacesApp() throws (TestError) -> Coordinates {
    placesApp.tabBars.buttons["Saved"].tap()
    
    // ensure no item with the same name exists
    if placesApp.staticTexts["My Test Location"].exists {
      placesApp.staticTexts["My Test Location"].swipeLeft()
      placesApp.buttons["Delete"].tap()
    }
    
    placesApp.buttons["Add New Saved Location"].tap()
    
    placesApp.textFields["Name"].tap()
    placesApp.textFields["Name"].typeText("My Test Location")
    
    placesApp.maps.firstMatch.swipeUp()
    
    // wait for the map scroll to end
    sleep(2)
    
    let parser = FloatingPointFormatStyle<Double>.number.parseStrategy
    
    guard let latitude = try? parser.parse(placesApp.staticTexts["Latitude Value"].label),
          let longitude = try? parser.parse(placesApp.staticTexts["Longitude Value"].label) else {
      throw .coordinateValuesNotReadable
    }
    
    placesApp.buttons["Save"].tap()
    
    return Coordinates(latitude: latitude, longitude: longitude)
  }
  
  /// Checks that the center coordinates from the MapKit map inside the Wikipedia app are within specified
  /// bounds.
  ///
  /// The map view is located in the view hierarchy using the "Map view" accessibility identifier and its
  /// accessibility value is used to obtain the coordinates, which are encoded in a string as <lat>,<long>.
  ///
  /// The method will wait for at most 10 seconds for the coordinates to become within the specified,
  /// bounds, or it will fail the test that this method is run in.
  ///
  /// - Parameters:
  ///   - latitude: the latitude in degrees
  ///   - longitude: the longitude in degrees
  ///   - accuracy: the latitude and longitude margin, expressed in degrees
  @MainActor
  private func waitForMapViewCoordinatesInWikipedia(
    latitude: Double,
    longitude: Double,
    accuracy: Double = 0.00001
  ) {
    let mapView = wikipediaApp.otherElements["Map view"]
    
    let exp = expectation(for: NSPredicate(block: { object, dict in
      guard let mapViewValue = MapViewAccessibilityValue(mapView: mapView) else {
        return false
      }
      
      return (
        abs(mapViewValue.latitude - latitude) < accuracy
        && abs(mapViewValue.longitude - longitude) < accuracy
      )
    }), evaluatedWith: nil)
    
    wait(for: [exp], timeout: 10)
  }
  
  enum TestError: Error {
    case wikipediaAppDidNotLaunch
    case mapViewDidNotAppear
    case mapViewWithInvalidAccessibiltyValue(String)
    
    case testLocationDidNotAppear
    case coordinateValuesNotReadable
  }
  
  
  /// Removes an app using the app's title by navigating through Springboard.
  /// - Parameter title: the display name of the app, as it is shown in the home screen / app library
  @MainActor
  func removeAppIfNeeded(title: String) {
    springboard.activate()
    
    // Navigate to the App Library
    let appLibrarySearchField = springboard.searchFields["App Library"]
    while !appLibrarySearchField.exists {
      springboard.swipeLeft()
    }
    
    // Search for app
    appLibrarySearchField.tap()
    appLibrarySearchField.typeText(title)
    
    
    // Long press for menu
    let appIcon = springboard.tables.icons[title]
    guard appIcon.waitForExistence(timeout: 1) else { return }
    appIcon.press(forDuration: 0.5)

    // Delete the app
    let elements = [
      springboard.buttons["Delete App"],
      springboard.alerts.buttons["Delete"]
    ]
    
    for element in elements {
      element.tap()
      element.waitForNonExistence(timeout: 0.5)
    }
  }
  
  @MainActor
  func testLaunchPerformance() throws {
    if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
      measure(metrics: [XCTApplicationLaunchMetric()]) {
        placesApp.launch()
      }
    }
  }
}
