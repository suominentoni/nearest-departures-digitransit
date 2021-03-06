import XCTest
@testable import NearestDeparturesDigitransit

fileprivate class MockHttp: HTTP {
    override func HTTPsendRequest(_ request: URLRequest,
                         callback: @escaping (String, String?) -> Void) -> Void {
        callback(testData, nil)
    }
}

class TransitDataTestsMockData: XCTestCase {
    override func setUp() {
        super.setUp()
        _TransitData.httpClient = MockHttp()
    }

    func test_stop_count() {
        let ex = self.expectation(description: "Returns correct amount of stops")
        TransitData.nearestStopsAndDepartures(0, lon: 0, callback: {stops in
            XCTAssertEqual(stops.count, 5)
            ex.fulfill()
        })
        self.wait(for: [ex], timeout: 2.0)
    }

    func test_stop_name() {
        let ex = self.expectation(description: "Returns stop name")
        TransitData.nearestStopsAndDepartures(0, lon: 0, callback: {stops in
            XCTAssertEqual(stops[0].name, "Hovioikeus P")
            ex.fulfill()
        })
        self.wait(for: [ex], timeout: 2.0)
    }

    func test_stop_platform() {
        let ex = self.expectation(description: "Adds platform to stop name if a platform code exists")
        TransitData.nearestStopsAndDepartures(0, lon: 0, callback: {stops in
            XCTAssertEqual(stops[1].name, "Hovioikeus, laituri 1")
            ex.fulfill()
        })
        self.wait(for: [ex], timeout: 2.0)
    }

    func test_stop_distance() {
        let ex = self.expectation(description: "Returns stop distance")
        TransitData.nearestStopsAndDepartures(0, lon: 0, callback: {stops in
            XCTAssertEqual(stops[0].distance, "<50")
            XCTAssertEqual(stops[1].distance, "243")
            ex.fulfill()
        })
        self.wait(for: [ex], timeout: 2.0)
    }

    func test_stop_coordinates() {
        let ex = self.expectation(description: "Returns stop coordinates")
        TransitData.nearestStopsAndDepartures(0, lon: 0, callback: {stops in
            XCTAssertEqual(stops[0].lat, 62.890498)
            XCTAssertEqual(stops[0].lon, 27.672156)
            ex.fulfill()
        })
        self.wait(for: [ex], timeout: 2.0)
    }

    func test_stop_codes() {
        let ex = self.expectation(description: "Returns stop codes")
        TransitData.nearestStopsAndDepartures(0, lon: 0, callback: {stops in
            XCTAssertEqual(stops[0].codeLong, "MATKA:7_201312")
            XCTAssertEqual(stops[0].codeShort, "-")
            XCTAssertEqual(stops[1].codeShort, "10 161")
            ex.fulfill()
        })
        self.wait(for: [ex], timeout: 2.0)
    }

    func test_departure_count() {
        let ex = self.expectation(description: "Returns correct amount of departures")
        TransitData.nearestStopsAndDepartures(0, lon: 0, callback: {stops in
            XCTAssertEqual(stops[0].departures.count, 5)
            ex.fulfill()
        })
        self.wait(for: [ex], timeout: 2.0)
    }

    func test_departure_time() {
        let ex = self.expectation(description: "Returns departure time")
        TransitData.nearestStopsAndDepartures(0, lon: 0, callback: {stops in
            XCTAssertEqual(stops[0].departures[0].realDepartureTime, 31320)
            ex.fulfill()
        })
        self.wait(for: [ex], timeout: 2.0)
    }

    func test_departure_time_format() {
        let ex = self.expectation(description: "Formats departure time correctly")
        let result1 = DepartureTime(60)
        let result2 = DepartureTime(46860)
        let result3 = DepartureTime(86460) // 24h 1min
        XCTAssertEqual(result1.toTime(), "00:01")
        XCTAssertEqual(result2.toTime(), "13:01")
        XCTAssertEqual(result3.toTime(), "00:01")
        ex.fulfill()
        self.wait(for: [ex], timeout: 2.0)
    }

    func test_stop_encode_decode() {
        let stop = Stop(name: "Test stop", lat: 62.890498, lon: 27.672156, distance: "100 m", codeLong: "1234567", codeShort: "123", departures: [])
        let stops = [stop]
        let data = NSKeyedArchiver.archivedData(withRootObject: stops)
        if let stops = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [Stop] {
            XCTAssert(stop == stops[0])
            XCTAssertEqual(stop.lat, stops[0].lat)
            XCTAssertEqual(stop.lon, stops[0].lon)
            XCTAssertEqual(stop.name, stops[0].name)
            XCTAssertEqual(stop.distance, stops[0].distance)
            XCTAssertEqual(stop.codeLong, stops[0].codeLong)
            XCTAssertEqual(stop.codeShort, stops[0].codeShort)
        }
    }
}
