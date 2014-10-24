//
//  NSDateExtension.swift
//  Greenhouse Monitor
//
//  Created by Jason Kusnier on 10/22/14.
//  Copyright (c) 2014 Jason Kusnier. All rights reserved.
//

import Foundation

extension NSDate
{
    convenience
    init(dateString:String) {
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        let d = dateStringFormatter.dateFromString(dateString)
        self.init(timeInterval:0, sinceDate:d!)
    }
    
    func localFormat () -> String {
        return NSDateFormatter.localizedStringFromDate(self, dateStyle: .ShortStyle, timeStyle: .LongStyle)
    }
}