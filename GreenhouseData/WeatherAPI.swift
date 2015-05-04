//
//  WeatherAPI.swift
//  Wee Greenhouse Monitor
//
//  Created by Jason Kusnier on 4/14/15.
//  Copyright (c) 2015 Jason Kusnier. All rights reserved.
//

import Foundation

public class WeatherAPI {

    var _temperature: Double?
    var _publishedAt: NSDate?
    
    let outsideUrl:NSURL = NSURL(string: "http://api.openweathermap.org/data/2.5/weather?zip=48901,us")!
    
    public init() {}
    
    public func refreshData(stationId: String, failure fail: (NSError? -> ())? = { error in println(error) }, success succeed: (() -> ())? = nil) {
        
        let jsonData = NSData(contentsOfURL: outsideUrl)
        if let jsonData = jsonData {
            var error: NSError?
            if let jsonDict = NSJSONSerialization.JSONObjectWithData(jsonData, options: nil, error: &error) as? NSDictionary {
                if (error == nil) {

                    if let main = jsonDict["main"] as? NSDictionary {
                        if let temperature = main["temp"] as? Double {
                            self._temperature = 1.8 * (temperature - 273) + 32
                        }
                    }

                    if let publishedAt = jsonDict["dt"] as? Double {
                        self._publishedAt = NSDate(timeIntervalSince1970: publishedAt)
                    }
                    
                    if let succeed = succeed {
                        succeed()
                    }
                } else {
                    if let fail = fail {
                        fail(error)
                    }
                }

            }
        }
    }
    
    public func temperature() -> Double? {
        return self._temperature
    }
    
    public func publishedAt() -> NSDate? {
        return self._publishedAt
    }
}