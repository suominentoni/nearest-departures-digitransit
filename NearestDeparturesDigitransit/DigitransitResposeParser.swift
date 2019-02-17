//
//  DigitransitResposeParser.swift
//  HSL Nearest Departures
//
//  Created by Toni Suominen on 14/10/2018.
//  Copyright © 2018 Toni Suominen. All rights reserved.
//

import Foundation

struct Coordinate {
    let lat: Double
    let lon: Double
}

class DigitransitResponseParser {
    static func parseStopsFromData(obj: [String: AnyObject]) throws -> [Stop]  {
        if let errors = obj["errors"] as? NSArray {
            if let dataFetchingException = errors.first(where: {e in
                if let errorType = (e as AnyObject)["errorType"] as? String {
                    return errorType == "DataFetchingException"
                }
                return false
            }) as? AnyObject,
                let message = dataFetchingException["message"] as? String,
                let range = message.range(of: "invalid agency-and-id: ") {
                let id = message[range.upperBound...]
                NSLog(message)
                throw TransitDataError.dataFetchingError(id: String(id), stop: nil)
            } else {
                NSLog("Error updating departures for stops")
                throw TransitDataError.unknownError
            }
        } else {
            let stopsData = unwrapStopsData(obj: obj)
            let stops = stopsData.map({stop in Stop(json: stop)})
            return stops.unwrapAndStripNils()
        }
    }

    static func unwrapStopsData(obj: [String: AnyObject]) -> [[String: AnyObject]] {
        if let data = obj["data"] as? [String: AnyObject],
            let stopsData = data["stops"] as? [[String: AnyObject]] {
            return stopsData
        }
        return []
    }

    static func parseDeparturesFromData(obj: [String: AnyObject]) -> [Departure] {
        return parseDepartures(unwrapSingleStopData(obj: obj))
    }

    static func parseCoordinatesFromData(obj: [String: AnyObject]) -> Coordinate {
        let stopData = unwrapSingleStopData(obj: obj)
        if let lat = stopData["lat"] as? Double,
            let lon = stopData["lon"] as? Double {
            return Coordinate(lat: lat, lon: lon)
        }
        return Coordinate(lat: 0, lon: 0)
    }

    static func unwrapSingleStopData(obj: [String: AnyObject]) -> [String: AnyObject] {
        if let data = obj["data"] as? [String: AnyObject],
            let stopData = data["stop"] as? [String: AnyObject] {
            return stopData
        }
        return [String: AnyObject]()
    }

    static func parseStopsAndDeparturesFromData(obj: [String: AnyObject]) -> [Stop] {
        var stops: [Stop?] = []
        if let data = obj["data"] as? [String: AnyObject],
            let stopsByRadius = data["stopsByRadius"] as? [String: AnyObject],
            let edges = stopsByRadius["edges"] as? NSArray {
            for edge in edges {
                stops.append(self.parseStopAtDistance(edge as AnyObject))
            }
        }
        return stops.unwrapAndStripNils()
    }

    static func parseNearestStopsFromData(obj: [String: AnyObject]) -> [Stop] {
        var stops: [Stop?] = []
        if let data = obj["data"] as? [String: AnyObject],
            let stopsByRadius = data["stopsByRadius"] as? [String: AnyObject],
            let edges = stopsByRadius["edges"] as? NSArray {
            for edge in edges {
                stops.append(DigitransitResponseParser.parseStopAtDistance(edge as AnyObject))
            }
        }
        return stops.unwrapAndStripNils()
    }

    static func parseRectStopsFromData(obj: [String: AnyObject]) -> [Stop] {
        var stops: [Stop?] = []
        if let data = obj["data"] as? [String: AnyObject],
            let stopsByBox = data["stopsByBbox"] as? NSArray {
            for stop in stopsByBox {
                if let stopJson = stop as? [String: Any] {
                        stops.append(Stop(json: stopJson))
                }
            }
        }
        return stops.unwrapAndStripNils()
    }

    fileprivate static func parseStopAtDistance(_ data: AnyObject) -> Stop? {
        if let stopAtDistance = data["node"] as? [String: AnyObject],
            let distance = stopAtDistance["distance"] as? Int,
            let stop = stopAtDistance["stop"] as? [String: AnyObject] {
            return Stop(json: stop, distance: distance)
        } else {
            return nil
        }
    }

    fileprivate static func parseDepartures(_ stopData: [String: AnyObject]) -> [Departure] {
        var deps: [Departure?] = []
        if let nextDeparturesData = stopData["stoptimesWithoutPatterns"] as? [[String: AnyObject]] {
            for dep: [String: AnyObject] in nextDeparturesData {
                deps.append(Departure(json: dep))
            }
        }
        return deps.unwrapAndStripNils()
    }
}
