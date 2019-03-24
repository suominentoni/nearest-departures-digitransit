//
//  Departure.swift
//  HSL Nearest Departures
//
//  Created by Toni Suominen on 14/10/2018.
//  Copyright © 2018 Toni Suominen. All rights reserved.
//

import Foundation
import UIKit

public struct Departure {
    public let line: Line
    public let scheduledDepartureTime: DepartureTime // seconds from midnight
    public let realDepartureTime: DepartureTime // seconds from midnight

    init?(json: [String: Any]) {
        if let scheduledDepartureTime = json["scheduledDeparture"] as? Int,
            let realDepartureTime = json["realtimeDeparture"] as? Int,
            let trip = json["trip"] as AnyObject?,
            let destination = trip["tripHeadsign"] as? String,
            let pickupType = json["pickupType"] as? String,
            let route = trip["route"] as? [String: AnyObject] {
            if(pickupType != "NONE") {
                let code = Departure.shortCodeForRoute(routeData: route)
                self.line = Line(
                    codeLong: code,
                    codeShort: code,
                    destination: destination
                )
                self.scheduledDepartureTime = scheduledDepartureTime
                self.realDepartureTime = realDepartureTime
            } else {
                return nil
            }
        } else {
            return nil
        }
    }

    fileprivate static func shortCodeForRoute(routeData: [String: AnyObject]) -> String {
        if let mode = routeData["mode"] as? String , mode == "SUBWAY" {
            return "Metro"
        }
        return routeData["shortName"] as? String ?? "-"
    }

    public func formattedDepartureTime() -> NSAttributedString {
        let scheduledTime = scheduledDepartureTime.toTime()
        let realTime = realDepartureTime.toTime()

        if(scheduledTime != realTime && abs(scheduledDepartureTime - realDepartureTime) >= 60) {
            let realString = NSMutableAttributedString(string: realTime)
            let space = NSAttributedString(string: " ")
            let scheduledString = NSMutableAttributedString(
                string: scheduledTime,
                attributes: [
                    NSAttributedString.Key.strikethroughStyle: 1,
                    NSAttributedString.Key.strikethroughColor: UIColor.lightGray,
                    NSAttributedString.Key.foregroundColor: UIColor.gray,
                    NSAttributedString.Key.baselineOffset: 0])
            scheduledString.append(space)
            scheduledString.append(realString)
            return scheduledString
        }
        return NSAttributedString(string: scheduledDepartureTime.toTime())
    }
}

extension Array where Element == Departure {
    public func hasShortCodes() -> Bool {
        return self.filter({ $0.line.codeShort != "-" }).count > 0
    }

    public func destinations() -> String {
        let destinations = self
            .reduce([String](), { (destinations, departure) in
                if let destination = departure.line.destination, destinations.contains(destination) == false {
                    return destinations + [destination]
                } else {
                    return destinations
                }
            })
            .joined(separator: ", ")
        return destinations.count == 0 ? "-" : destinations
    }
}

extension Array where Element == Optional<Departure> {
    public func unwrapAndStripNils() -> [Departure] {
        return self.filter({$0 != nil}).map({$0!})
    }
}
