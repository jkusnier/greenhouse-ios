//
//  NSDateExtension.swift
//  Wee Greenhouse Monitor
//
//  Created by Jason Kusnier on 4/6/15.
//  Copyright (c) 2015 Jason Kusnier. All rights reserved.
//

import Foundation

public extension NSDate
{
    convenience
    public init(dateString:String) {
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        let d = dateStringFormatter.dateFromString(dateString)
        self.init(timeInterval:0, sinceDate:d!)
    }
    
    public func localFormat () -> String {
        return NSDateFormatter.localizedStringFromDate(self, dateStyle: .ShortStyle, timeStyle: .LongStyle)
    }
    
    public func relativeDateFormat() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = .ShortStyle
        dateFormatter.doesRelativeDateFormatting = true
        
        return dateFormatter.stringFromDate(self)
    }
}