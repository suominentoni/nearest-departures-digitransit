
# Nearest Departures Digitransit

A Swift framework for fetching transit data (stops and their departures, to be more exact) from the Digitransit API (https://digitransit.fi/en/developers/). Originally written specifically for the Nearest Departures Finland app only ([Download for iOS and Apple Watch](https://itunes.apple.com/fi/app/hsl-lahimmat-lahdot/id1137708015?mt=8) or see the [source code](https://github.com/suominentoni/nearest-departures)), not for general use. However, I decided to extract it into a separate framework, in case someone finds it useful. Additionally, I'll try to develop it towards a more generic framework. Feel free to contribute!

Transit data provided by [Digitransit](https://digitransit.fi/en/developers/).

## API

In short, the API returns [Stops](https://github.com/suominentoni/nearest-departures-digitransit/blob/master/NearestDeparturesDigitransit/Model/Stop.swift) and [Departures](https://github.com/suominentoni/nearest-departures-digitransit/blob/master/NearestDeparturesDigitransit/Model/Departure.swift).

Nearest Departures Digitransit exposes an object named `TransitData`, with the following methods:

```swift
TransitData.nearestStopsAndDepartures(
    lat: Double,
    lon: Double,
    radius: Int = 5000,
    stopCount: Int = 30,
    departureCount: Int = 30,
    callback: (stops: [Stop]) -> Void) -> Void
```

```swift
TransitData.nearestStops(lat: Double, lon: Double, callback: (stops: [Stop]) -> Void) -> Void
```

```swift
TransitData.stopsForRect(minLat: Double, minLon: Double, maxLat: Double, maxLon: Double, callback: (stops: [Stop]) -> Void) -> Void
```

```swift
TransitData.stopsByCodes(codes: [String], callback: (stops: [Stop], error: TransitDataError?) -> Void) -> Void
```

```swift
TransitData.departuresForStop(gtfsId: String, callback: (departures: [Departure]) -> Void) -> Void
```

```swift
TransitData.coordinatesForStop(stop: Stop, callback: (lat: Double, lon: Double) -> Void) -> Void
```

```swift
TransitData.updateDeparturesForStops(stops: [Stop], callback: (stopsWithDepartures: [Stop], error: TransitDataError?) -> Void) -> Void
```


## Installation

Add the following to your Podfile

`pod 'NearestDeparturesDigitransit', :git => 'https://github.com/suominentoni/nearest-departures-digitransit.git'`

Install pods

`pod install`

## Contribute

Use [GitHub issues](https://github.com/suominentoni/nearest-departures/issues) and [Pull Requests](https://github.com/suominentoni/nearest-departures/pulls).

