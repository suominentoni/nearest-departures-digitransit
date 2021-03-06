//
//  NearestDeparturesDigitransitTests.swift
//  NearestDeparturesDigitransitTests
//
//  Created by Toni Suominen on 11/01/2019.
//  Copyright © 2019 Toni Suominen. All rights reserved.
//

import XCTest
@testable import NearestDeparturesDigitransit

class NearestDeparturesDigitransitTests: XCTestCase {
    let lat = 62.914898
    let lon = 27.707004
    let timeout = 10.0
    
    override func setUp() {
        _TransitData.httpClient = HTTP()
    }

    override func tearDown() {
        super.tearDown()
    }

    func test_stop_count() {
        let ex = self.expectation(description: "Returns correct amount of stops")
        TransitData.nearestStopsAndDepartures(lat, lon: lon, callback: {stops in
            XCTAssert(stops.count > 20 && stops.count < 35) // Note: API randomly returns a different amount of stops
            ex.fulfill()
        })
        self.wait(for: [ex], timeout: timeout)
    }
    
    func test_stop_name() {
        let ex = self.expectation(description: "Returns stop name")
        TransitData.nearestStopsAndDepartures(lat, lon: lon, callback: {stops in
            XCTAssertEqual(stops[0].name, "Ankkuritie E")
            ex.fulfill()
        })
        self.wait(for: [ex], timeout: timeout)
    }
    
    func test_stop_distance() {
        let ex = self.expectation(description: "Returns stop distance")
        TransitData.nearestStopsAndDepartures(lat, lon: lon, callback: {stops in
            XCTAssertEqual(stops[0].distance, "<50")
            XCTAssert(stops[1].distance == "59" || stops[1].distance == "60")
            ex.fulfill()
        })
        self.wait(for: [ex], timeout: timeout)
    }
    
    func test_stop_coordinates() {
        let ex = self.expectation(description: "Returns stop coordinates")
        TransitData.nearestStopsAndDepartures(lat, lon: lon, callback: {stops in
            XCTAssertEqual(stops[0].lat, 62.914877)
            XCTAssertEqual(stops[0].lon, 27.706835)
            ex.fulfill()
        })
        self.wait(for: [ex], timeout: timeout)
    }
    
    func test_stop_codes() {
        let ex = self.expectation(description: "Returns stop codes")
        TransitData.nearestStopsAndDepartures(lat, lon: lon, callback: {stops in
            XCTAssertEqual(stops[0].codeLong, "MATKA:7_201269")
            XCTAssertEqual(stops[0].codeShort, "1641")
            ex.fulfill()
        })
        self.wait(for: [ex], timeout: timeout)
    }
    
    func test_departure_count() {
        let ex = self.expectation(description: "Returns correct amount of departures")
        TransitData.nearestStopsAndDepartures(lat, lon: lon, callback: {stops in
            XCTAssertEqual(stops.first?.departures.count ?? 0, 30)
            ex.fulfill()
        })
        self.wait(for: [ex], timeout: timeout)
    }
    
    func test_departure_information() {
        let ex = self.expectation(description: "Returns departure information")
        TransitData.nearestStopsAndDepartures(lat, lon: lon, callback: {stops in
            // Destinations vary depending on the time of the day
            XCTAssertTrue(
                stops[0].departures[0].line.destination == "Neulamäki P" ||
                    stops[0].departures[0].line.destination == "Tukkipoika I"
            )
            XCTAssertEqual(stops[0].departures[0].line.codeShort, "4")
            // Destinations vary depending on the time of the day
            XCTAssertTrue(
                stops[0].departures.destinations().contains("Neulamäki P") ||
                    stops[0].departures.destinations().contains("Tukkipoika I")
            )
            ex.fulfill()
        })
        self.wait(for: [ex], timeout: timeout)
    }
    
    func test_error_on_invalid_departures_update() {
        let ex = self.expectation(description: "Returns departure information")
        let invalidStop = Stop(name: "invalid stop", lat: 0.0, lon: 0.0, distance: "0", codeLong: "invalid long code", codeShort: "invalid short code", departures: [])
        TransitData.updateDeparturesForStops([invalidStop], callback: {stops, error in
            XCTAssertEqual(stops, [Optional(invalidStop)])
            XCTAssertEqual(error!.localizedDescription, "The operation couldn’t be completed. (NearestDeparturesDigitransit.TransitDataError error 0.)")
            ex.fulfill()
        })
        self.wait(for: [ex], timeout: timeout)
    }
    
    func test_coordinates_for_stop() {
        let ex = self.expectation(description: "Returns departure information")
        let stop = Stop(name: "Hovioikeus", lat: 0.0, lon: 0.0, distance: "", codeLong: "MATKA:201312", codeShort: "10 161", departures: [])
        TransitData.coordinatesForStop(stop, callback: {lat, lon in
            XCTAssertEqual(lat, 62.890472)
            XCTAssertEqual(lon, 27.672057)
            ex.fulfill()
        })
        self.wait(for: [ex], timeout: timeout)
    }
    
    func test_departures_for_stop() {
        let ex = self.expectation(description: "Returns departure information")
        TransitData.departuresForStop("MATKA:7_201834", callback: {departures in
            XCTAssertEqual(departures.first?.line.destination ?? "", "Touvitie")
            ex.fulfill()
        })
        self.wait(for: [ex], timeout: timeout)
    }
    
    func test_stops_for_rect() {
        let ex = self.expectation(description: "Returns departure information")
        TransitData.stopsForRect(minLat: 62.914700, minLon: 27.706297, maxLat: 62.915477, maxLon: 27.707981, callback: {stops in
            XCTAssertEqual(stops.count, 2)
            XCTAssertTrue(stops.contains(where: {$0.name == "Ankkuritie P"}))
            XCTAssertTrue(stops.contains(where: {$0.name == "Ankkuritie E"}))
            ex.fulfill()
        })
        self.wait(for: [ex], timeout: timeout)
    }
    
    func test_stops_by_codes() {
        let ex = self.expectation(description: "Returns departure information")
        TransitData.stopsByCodes(codes: ["MATKA:7_201270", "MATKA:7_201269"], callback: {stops, error  in
            XCTAssertEqual(stops.count, 2)
            XCTAssertTrue(stops.contains(where: {$0.name == "Ankkuritie P"}))
            XCTAssertTrue(stops.contains(where: {$0.name == "Ankkuritie E"}))
            ex.fulfill()
        })
        self.wait(for: [ex], timeout: timeout)
    }
    
    func test_unwrapAndStripNils() {
        let ex = self.expectation(description: "Returns departure information")
        let stop1: Stop? = Stop(name: "foo", lat: 0, lon: 0, distance: "1", codeLong: "", codeShort: "", departures: [])
        let stop2: Stop? = Stop(name: "bar", lat: 0, lon: 0, distance: "1", codeLong: "", codeShort: "", departures: [])
        let nilStop: Stop? = nil
        let stops = [stop1, stop2, nilStop]
        let expected = [stop1!, stop2!]
        XCTAssertEqual(stops.unwrapAndStripNils(), expected)
        ex.fulfill()
        self.wait(for: [ex], timeout: timeout)
    }
}
