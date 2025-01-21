# ABN AMRO iOS Assignment Preamble

This is an adjusted version of the Wikipedia iOS app project, containing the
implementation of ABN Amro's iOS assignment.

Following this top-level section is the rest of the Wikipedia iOS project's 
original README content.

## How to run the customized Wikipedia app and the demo app

- Open the project in Xcode
- Select a simulator target (see design decisions)
- Run the `Wikipedia` app target
- Run the `abnamro-places` app target

### Tests

Select the `abnamro-places` scheme and run these test targets:
- `abnamro-placesTests`
- `abnamro-placesUITests`  

## Requirements

- Wikipedia iOS can be called from other apps with a specific URL to show a 
specific location in the places tab
- A demo app that demonstrates this feature

The specific requirements are in `ios-assignment-2024.pdf`, located in the root
of the repository.

## High Level Implementation

### Wikipedia App

The Wikipedia app now also accepts URLs in the following format:

```
wikipedia://places?WMFPlacesLatLong=52.5,4.56
```

Opening a URL of this kind on the device will trigger iOS to call one of the 
following methods in the Wikipedia app, depending on the app state:
- `UISceneDelegate.scene(_:, openURLContexts:)` (app already running))
- `scene(_:, willConnectTo:, options:)` (when launched, with 
  `options.urlContexts` being populated)

Wikipedia already has custom URL schemes implemented, and the current 
implementation makes use of what is already there. The existing implementation
of the handling for the `wikipedia://places` URl is extended with a 
`WMFPlacesLatLong` query string parameter.

The `PlacesViewController` is updated with a new `show(location:)` method that
will center the given location on the map.

### Demo App

The demo app is implemented using SwiftUI with a main tab scene and two main
views. Both views have a model that either uses a web API or Swift Data for its
data.

The "saved locations" view uses an Apple Map, sadly without location support, 
because I was out of time.

The models and utility methods in the app are unit tested and there are UI tests
for testing the Wikipedia app's URL handling and for the demo app's 
functionality, including triggering the Wikipedia app with the right URL. 

## Project structure

The implementation is housed in a fork of the Wikipedia iOS repository, in the
branch `feature/abnamro-ios-places`. The reason for this is simply because it is
 easy.

The changes to the wikipedia app have been made in the `Wikipedia` app target in
 the main project.

The additional demo app and its tests are implemented using a set of targets in
the main project:
- `abmamro-places`
- `abmamro-placesTests`
- `abmamro-placesUITests`

## Design Decisions / Rationale

### Signing and running on device

I am not supporting running this version of Wikipedia on a device.

I have deliberately left the team to Wikipedia's original `AKK7J2GV64` and
decided _not_ to change the bundle IDs, which would have been needed to support
running it on a device. Changing the bundle ID may require references to this 
bundle ID in other places to be changed and an App ID to be setup in my own
(paid) account. Although fixing signing issues is definitely a good skill to 
demonstrate, being able to see that it works requires doing pretty much the 
same work on your end, so I have decided to leave this alone.

If you're disappointed, please do let me know.

### URL

On iOS, the only proper way to launch one app from another app while passing
parameters is using URLs. The chosen method is to use a custom scheme. As the
Wikipedia app already has custom schemes implemented, we make use of the already
 available `wikipedia:` scheme.

The following command allows us to test launching URLs on the simulator, without
needing a demo app just yet:
```
xcrun simctl openurl booted 'wikipedia://places?WMFPlacesLatLong=52.3547498,4.8339215'
```

### Tightly Integrating SwiftData into Model

Whereas the `APILocationsModel` has a nicely injectable dependency, the
`SavedLocationsModel` needs a `ModelContext`. Normally, I would try to keep the
models as pure as possible, but SwiftData containers are easily testable, 
because they can be configured to persist data only in memory.

For SwiftUI previews and unit tests this is already very useful. For larger
scale projects it I think it pays to keep the SwiftData out of your models, in 
case you every want to move away from Swift Data without having to refactor
everything.

### Not using the Wikipedia UI Tests target

I added the tests for the Wikipedia app to my new target
`abnamro-placesUITests`, because there was an issue that prevented my tests from
working normally in the Wikipedia UI Tests target.

At a later point, I found out that it was this line, causing the unexpected view
controller to be shown:
```swift
// ExploreViewController.swift:102
#if UITEST
        presentUITestHelperController()
#endif
```

At first I could not figure out where this weird screen was coming from, but
when I figured it out, I decided to leave it at this. It's more logical to have
the tests in the Wikipedia target, but I think this is not particularly 
interesting problem to solve at this point.

#### Custom HTTPS URLs (alternative considered)

The app already makes use of the universal links feature of iOS, so we could
choose to piggy back on this implementation. This would mean we would need to
need to use the `https` scheme in the URL and use one of its associated domains
as the host, such as `wikipedia.org`, but then add either a custom path, query 
string parameter or fragment.

Examples:
```
https://wikipedia.org/wiki/places/52.3547498,4.8339215
https://wikipedia.org/wiki?coordinates=52.3547498,4.8339215
https://wikipedia.org/wiki/#coordinates=52.3547498,4.8339215
```

The
[apple-app-site-association](https://wikipedia.org/apple-app-site-association)
file hosted by Wikipedia lists several `applinks` items, all of them specifying
the `/wiki/*` subpath, which means we have to use this subpath, otherwise our 
links will not trigger the app, but simply to to the website.

This can work, but implementing it like this still does not entirely prevent the
possibility of the browser being used to open these URLs, which will lead to
confusing results, such as a 4xx, 5xx response or simply loading the Wikipedia 
homepage wihout anything happening.

Before moving on to the custom scheme implementation, we will use the universal
links as an intermediate version to reduce the scope of single changes.

Before having implemented the demo application or UI tests, we use the following
command-line command to test the URLs:

```
xcrun simctl openurl booted 'https://en.wikipedia.org/wiki#coordinates=1,2'
```

# Wikipedia iOS
The official Wikipedia iOS app.

[![Wikipedia](https://circleci.com/gh/wikimedia/wikipedia-ios.svg?style=shield)](https://github.com/wikimedia/wikipedia-ios)
[![MIT license](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://raw.githubusercontent.com/wikimedia/wikipedia-ios/main/LICENSE.txt)

* **License**: MIT License
* **Source repo**: https://github.com/wikimedia/wikipedia-ios
* **Planning (bugs & features)**: https://phabricator.wikimedia.org/project/view/782/
* **Team page**: https://www.mediawiki.org/wiki/Wikimedia_Apps/Team/iOS

## Building and Running

Note: Your Xcode version must be at least 16.0.
In the directory, run `./scripts/setup`.  Note: going to `scripts` directory and running `setup` will not work due to relative paths.

Running `scripts/setup` will setup your computer to build and run the app. The script assumes you have Xcode installed already. It will install [homebrew](https://brew.sh), [SwiftLint](https://github.com/realm/SwiftLint), and [ClangFormat](https://clang.llvm.org/docs/ClangFormat.html). It will also create a pre-commit hook that uses ClangFormat for linting Objective-C code.

After running `scripts/setup`, you should be able to open `Wikipedia.xcodeproj` and run the app on the iOS Simulator (using the **Wikipedia** scheme and target). If you encounter any issues, please don't hesitate to let us know via a [bug report](https://phabricator.wikimedia.org/maniphest/task/edit/form/1/?title=[BUG]&projects=wikipedia-ios-app-product-backlog,ios-app-bugs&description=%3D%3D%3D+How+many+times+were+you+able+to+reproduce+it?%0D%0A%0D%0A%3D%3D%3D+Steps+to+reproduce%0D%0A%23+%0D%0A%23+%0D%0A%23+%0D%0A%0D%0A%3D%3D%3D+Expected+results%0D%0A%0D%0A%3D%3D%3D+Actual+results%0D%0A%0D%0A%3D%3D%3D+Screenshots%0D%0A%0D%0A%3D%3D%3D+Environments+observed%0D%0A**App+version%3A+**+%0D%0A**OS+versions%3A**+%0D%0A**Device+model%3A**+%0D%0A**Device+language%3A**+%0D%0A%0D%0A%3D%3D%3D+Regression?+%0D%0A%0D%0A+Tag++task+with+%23Regression+%0A).

### Required Dependencies
If you'd rather install the development prerequisites yourself without our script:

* [**Xcode**](https://itunes.apple.com/us/app/xcode/id497799835) - The easiest way to get Xcode is from the [App Store](https://itunes.apple.com/us/app/xcode/id497799835?mt=12), but you can also download it from [developer.apple.com](https://developer.apple.com/) if you have an Apple ID registered with an Apple Developer account.
* [**SwiftLint**](https://github.com/realm/SwiftLint) - We use this for linting Swift code.
* [**ClangFormat**](https://clang.llvm.org/docs/ClangFormat.html) - We use this for linting Objective-C code.

## Contributing
Covered in the [contributing document](CONTRIBUTING.md).

## Development Guidelines
These are general guidelines rather than hard rules.

### Coding Guidelines
- **Objective-C** - [Apple's Coding Guidelines for Cocoa](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/CodingGuidelines/CodingGuidelines.html)
- **Swift** - [swift.org API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)

### Formatting
We use Xcode's default 4 space indentation and our `.clang-format` file with the pre-commit hook setup by `scripts/setup`. Where possible, our Swift code is automatically formatted by [SwiftLint](https://github.com/realm/SwiftLint) based on the rules defined in `.swiftlint-autocorrect.yml`.

### Process and Code Review Norms
Covered in the [process document](docs/process.md).

### Logging
When reading logs, note that the log levels are shortened to emoji.
- 🗣️ Verbose
- 💬 Debug
- ℹ️ Info
- ⚠️ Warning
- 🚨 Error

 The app only writes Warning and Error messages to the console for both Debug and Release mode. If you need to log all messages temporarily during troubleshooting, update [this level](https://github.com/wikimedia/wikipedia-ios/blob/main/Wikipedia/Code/WMFLogging.h#L6) to DDLogLevelAll.  

### Testing
The **Wikipedia** scheme is configured to execute the project's iOS unit tests, which can be run using the `Cmd+U` hotkey or the **Product → Test** menu bar action. In order for the tests to pass, the test device's language and region must be set to `en-US` in Settings → General → Language & Region. There is a [ticket filed](https://phabricator.wikimedia.org/T259859) to update the tests to pass regardless of language and region.

### Schemes and Targets

* **Wikipedia** - Points to production servers. 
* **Staging** -  Points to various staging server environments. You can adjust these environments by changing the `current` [property](WMF%20Framework/Configuration.swift#L41) of `Configuration`:
    - An option of `appsLabsForPCS` will point to the [Apps team's staging environment](https://mobileapps.wmflabs.org) for page content.
    - An option of `betaCluster` will point to the [MediaWiki beta cluster environment](https://www.mediawiki.org/wiki/Beta_Cluster) for most API calls. This is meant to be a more blanket environment setting, so if this value exists it will also force the beta cluster environment for page content on the article view. This beta cluster environment is also where developers can test sandbox push notifications triggered across various wikis. This is selected by default.
    
    The Staging scheme also has our feature flags set to true. It displays features that are still in development. It is pushed to TestFlight as a separate app.
* **Experimental** - For one-off builds, to demonstrate early development or prototype features. This points to production servers by default, but can be adjusted to whatever server environment is needed via temporary adjustments in `Configuration`. We also sometimes use it for design review, before features go through PR review. It is pushed to TestFlight as a separate app.

* **Local Page Content Service and Announcements** - used by engineers in Debug-mode only. This has the ability to toggle different local environments within the `current` [property](WMF%20Framework/Configuration.swift#L41) of `Configuration`:
    - An option of `localPCS` will point to a locally running [mobileapps](https://gerrit.wikimedia.org/r/q/project:mediawiki%252Fservices%252Fmobileapps) repository for page content. This is selected by default.
    - An option of `localAnnouncements` will point to a locally running [wikifeeds](https://gerrit.wikimedia.org/r/q/project:mediawiki%252Fservices%252Fwikifeeds) repository for the announcements endpoint. This is selected by default.
    -  All other endpoints will point to production.
* **RTL** - Launches the app in an RTL locale using the `-AppleLocale` launch argument. This is used by engineers in Debug-mode only. 
* **Performance Testing** - This is a duplicate scheme of Wikipedia, but uses the Release configuration in its Run step instead of Debug. We use this scheme when we manually run performance tests as a part of our pre-release checklist.  

* **WMF** - Bundles up the app logic shared between the main app and the extensions (widgets, notifications).
* **Update Localizations** - Covered in the [localization document](docs/localization.md).
* **Update Languages** - For adding new Wikipedia languages or updating language configurations. Covered in the [languages document](docs/languages.md).
* **{{name}}Widget, {{name}}Notification, {{name}}Stickers** - Extensions for widgets, notifications, and stickers.

### Continuous Integration
Covered in the [CI document](docs/ci.md).

### Web Development
The article view and several other components of the app rely on web components. Instructions for working on these components are covered in the [web development document](docs/web_dev.md).

### Contact Us
If you have any questions or comments, you can email us at ios-support[at]wikimedia dot org. We'll also gladly accept any [bug reports](https://phabricator.wikimedia.org/maniphest/task/edit/form/1/?title=[BUG]&projects=wikipedia-ios-app-product-backlog,ios-app-bugs&description=%3D%3D%3D+How+many+times+were+you+able+to+reproduce+it?%0D%0A%0D%0A%3D%3D%3D+Steps+to+reproduce%0D%0A%23+%0D%0A%23+%0D%0A%23+%0D%0A%0D%0A%3D%3D%3D+Expected+results%0D%0A%0D%0A%3D%3D%3D+Actual+results%0D%0A%0D%0A%3D%3D%3D+Screenshots%0D%0A%0D%0A%3D%3D%3D+Environments+observed%0D%0A**App+version%3A+**+%0D%0A**OS+versions%3A**+%0D%0A**Device+model%3A**+%0D%0A**Device+language%3A**+%0D%0A**App+language%3A**+%0D%0A%0D%0A%3D%3D%3D+Regression?+%0D%0A%0D%0A+Tag++task+with+%23Regression+%0A).
