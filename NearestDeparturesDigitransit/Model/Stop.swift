//
//  Stop.swift
//  HSL Nearest Departures
//
//  Created by Toni Suominen on 14/10/2018.
//  Copyright © 2018 Toni Suominen. All rights reserved.
//

import Foundation

open class Stop: NSObject, NSCoding {
    public var name: String = ""
    public var lat: Double = 0.0
    public var lon: Double = 0.0
    public var distance: String = ""
    public var codeLong: String = ""
    public var codeShort: String = ""
    public var departures: [Departure] = []
    public var nameWithCode: String {
        get {
            return codeShort == "-"
                ? "\(name)"
                : "\(name) (\(codeShort))"
        }
    }

    public override init() {
        super.init()
    }

    public init(name: String, lat: Double, lon: Double, distance: String, codeLong: String, codeShort: String, departures: [Departure]) {
        self.name = name
        self.lat = lat
        self.lon = lon
        self.distance = distance
        self.codeLong = codeLong
        self.codeShort = codeShort
        self.departures = departures
    }

    init?(json: [String: Any], distance: Int = 0) {
        if let name = json["name"] as? String,
            let lat = json["lat"] as? Double,
            let lon = json["lon"] as? Double,
            let gtfsId = json["gtfsId"] as? String {
            var stopName: String = name
            if let platformCode = json["platformCode"] as? String {
                stopName = Stop.formatStopName(name, platformCode: platformCode)
            }
            if let nextDeparturesData = json["stoptimesWithoutPatterns"] as? [[String: AnyObject]] {
                self.departures = nextDeparturesData.map({Departure(json: $0)}).unwrapAndStripNils()
            }
            self.name = stopName
            self.lat = lat
            self.lon = lon
            self.distance = Stop.formatDistance(distance)
            self.codeLong = gtfsId
            self.codeShort = Stop.shortCodeForStop(stopData: json)
        } else {
            return nil
        }
    }

    fileprivate static func shortCodeForStop(stopData: [String: Any]) -> String {
        // Some public transit operators (e.g. the one in Jyväskylä)
        // don't have a code field for their stops.
        if let shortCode = stopData["code"] as? String {
            return shortCode
        } else {
            return "-"
        }
    }

    fileprivate static func formatDistance(_ distance: Int) -> String {
        return distance <= 50 ? "<50" : String(distance)
    }

    fileprivate static func formatStopName(_ name: String, platformCode: String?) -> String {
        return platformCode != nil ? "\(name), laituri \(platformCode!)" : name
    }

    public required init?(coder aDecoder: NSCoder) {
        if let name = aDecoder.decodeObject(forKey: "name") as? String,
            let distance = aDecoder.decodeObject(forKey: "distance") as? String,
            let codeLong = aDecoder.decodeObject(forKey: "codeLong") as? String,
            let codeShort = aDecoder.decodeObject(forKey: "codeShort") as? String {
            var lat = 0.0
            var lon = 0.0
            do {
                try ObjC.catchException {
                    lat = aDecoder.decodeDouble(forKey: "lat")
                    lon = aDecoder.decodeDouble(forKey: "lon")
                }
            }
            catch let error {
                NSLog("Unable to decode coordinates for stop: \(error)")
            }

            self.lat = lat
            self.lon = lon
            self.name = name
            self.distance = distance
            self.codeLong = codeLong
            self.codeShort = codeShort
        }
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.lat, forKey: "lat")
        aCoder.encode(self.lon, forKey: "lon")
        aCoder.encode(self.distance, forKey: "distance")
        aCoder.encode(self.codeLong, forKey: "codeLong")
        aCoder.encode(self.codeShort, forKey: "codeShort")
    }

    public func hasCoordinates() -> Bool {
        return self.lat != 0.0 && self.lon != 0.0
    }
}

public func == (lhs: Stop, rhs: Stop) -> Bool {
    return lhs.codeLong == rhs.codeLong
}

public  func != (lhs: Stop, rhs: Stop) -> Bool {
    return lhs.codeLong != rhs.codeLong
}

extension Array where Element:Stop {
    public func hasShortCodes() -> Bool {
        return self.filter({ $0.codeShort != "-" }).count > 0
    }
}

extension Array where Element == Optional<Stop> {
    public func unwrapAndStripNils() -> [Stop] {
        return self.filter({$0 != nil}).map({$0!})
    }
}
