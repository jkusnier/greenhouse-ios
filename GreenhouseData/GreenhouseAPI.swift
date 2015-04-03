//
//  GreenhouseAPI.swift
//  Wee Greenhouse Monitor
//
//  Created by Jason Kusnier on 4/2/15.
//  Copyright (c) 2015 Jason Kusnier. All rights reserved.
//

import Foundation

public class GreenhouseAPI {
    
    public func refreshData(failure fail: (NSError? -> ())? = { error in println(error) }, success succeed: (() -> ())? = nil) {
        if let succeed = succeed {
            succeed()
        }
    }
    
    public func temperature() -> Double {
        return 0 as Double
    }
    
    public func humidity() -> Int {
        return 0 as Int
    }
    
    public func publishedAt() -> NSDate {
        return NSDate()
    }
}