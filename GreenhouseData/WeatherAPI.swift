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
    
    public init() {}
    
    public func refreshData(stationId: String, failure fail: (NSError? -> ())? = { error in println(error) }, success succeed: (() -> ())? = nil) {
    }
    
    public func temperature() -> Double? {
        return self._temperature
    }
    
    public func publishedAt() -> NSDate? {
        return self._publishedAt
    }
}