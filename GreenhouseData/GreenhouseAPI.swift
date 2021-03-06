//
//  GreenhouseAPI.swift
//  Wee Greenhouse Monitor
//
//  Created by Jason Kusnier on 4/2/15.
//  Copyright (c) 2015 Jason Kusnier. All rights reserved.
//

import Foundation

public class GreenhouseAPI {
    
    var _temperature: Double?
    var _humidity: Int?
    var _publishedAt: NSDate?
    
    public init() {}
    
    public func refreshData(deviceId: String, failure fail: (NSError? -> ())? = { error in println(error) }, success succeed: (() -> ())? = nil) {
        if let envUrl = NSURL(string: "http://api.weecode.com/greenhouse/v1/devices/\(deviceId)/environment") {
            let jsonData = NSData(contentsOfURL: envUrl)
            if let jsonData = jsonData {
                var error: NSError?
                if let jsonDict = NSJSONSerialization.JSONObjectWithData(jsonData, options: nil, error: &error) as? NSDictionary {
                
                    if (error == nil) {
                        if let temperature = jsonDict["fahrenheit"] as? Double {
                            self._temperature = temperature
                        }
                        if let humidity = jsonDict["humidity"] as? Int {
                            self._humidity = humidity
                        }
                        
                        if let publishedAt = jsonDict["published_at"] as? String {
                            self._publishedAt = NSDate(dateString: publishedAt)
                        } else {
                            self._publishedAt = nil
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
        } else {
            if let fail = fail {
                fail(nil)
            }
        }
    }
    
    public func temperature() -> Double? {
        return self._temperature
    }
    
    public func humidity() -> Int? {
        return self._humidity
    }
    
    public func publishedAt() -> NSDate? {
        return self._publishedAt
    }
}