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
    
    let outsideUrl:NSURL = NSURL(string: "http://api.weecode.com/greenhouse/v1/weather/STATION-HERE/fahrenheit/now")!
    
    public init() {}
    
    public func refreshData(stationId: String, failure fail: (NSError? -> ())? = { error in println(error) }, success succeed: (() -> ())? = nil) {
        
        let jsonData = NSData(contentsOfURL: outsideUrl)
        if let jsonData = jsonData {
            var error: NSError?
            if let jsonDict = NSJSONSerialization.JSONObjectWithData(jsonData, options: nil, error: &error) as? NSDictionary {
                if (error == nil) {
                    if let temperature = jsonDict["temp_f"] as? Double {
                        self._temperature = temperature
                    }
                    
                    if let publishedAt = jsonDict["time"] as? String {
                        self._publishedAt = NSDate(dateString: publishedAt)
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