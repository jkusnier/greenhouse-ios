//
//  InterfaceController.swift
//  Wee Greenhouse Monitor WatchKit Extension
//
//  Created by Jason Kusnier on 3/8/15.
//  Copyright (c) 2015 Jason Kusnier. All rights reserved.
//

import WatchKit
import Foundation


class GlanceController: WKInterfaceController {

    @IBOutlet weak var temperatureLabel: WKInterfaceLabel!
    @IBOutlet weak var lastUpdated: WKInterfaceLabel!

    var limitLow: Double = 38
    var limitHigh: Double = 85
    
    let limitLowColor = UIColor(red: 132/255, green: 183/255, blue: 255/255, alpha: 1) //UIColor.blueColor()
    let limitHighColor = UIColor(red: 237/255, green: 88/255, blue: 141/255, alpha: 1) //UIColor.redColor()
    let limitNormalColor = UIColor(red: 188/255, green: 226/255, blue: 158/255, alpha: 1) //UIColor.greenColor()
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        updateTitle()
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func updateTitle() {
        var tempString = "--°"
        var humidityString = "---%"
        if let envUrl = NSURL(string: "http://api.weecode.com/greenhouse/v1/devices/50ff6c065067545628550887/environment") {
            let jsonData = NSData(contentsOfURL: envUrl)
            if let jsonData = jsonData? {
                var error: NSError?
                let jsonDict = NSJSONSerialization.JSONObjectWithData(jsonData, options: nil, error: &error) as NSDictionary
                
                
                if (error == nil) {
                    tempString = String(format: "%.1f°", jsonDict["fahrenheit"] as Double)
                    setBackgroundColor(jsonDict["fahrenheit"] as Double)
                    humidityString = String(format: "%d%%", jsonDict["humidity"] as Int)
                    if let publishedAt = jsonDict["published_at"] as? String {
                        
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                        let date = dateFormatter.dateFromString(publishedAt)
                        
                        if let date = date {
                            
                            let dateFormatter = NSDateFormatter()
                            dateFormatter.dateStyle = .ShortStyle
                            dateFormatter.timeStyle = .ShortStyle
                            dateFormatter.doesRelativeDateFormatting = true

                            let dateStr = dateFormatter.stringFromDate(date)
                            lastUpdated.setText(dateStr)
                        }
                    }
                }
            }
        }
        self.temperatureLabel.setText(tempString)
//        humidityLabel.text = humidityString
        
    }
    
    func setBackgroundColor(temperature: Double) {
        if (temperature <= limitLow) {
            self.temperatureLabel.setTextColor(self.limitLowColor)
            self.lastUpdated.setTextColor(self.limitLowColor)
        } else if (temperature >= limitHigh) {
            self.temperatureLabel.setTextColor(self.limitHighColor)
            self.lastUpdated.setTextColor(self.limitHighColor)
        } else {
            self.temperatureLabel.setTextColor(self.limitNormalColor)
            self.lastUpdated.setTextColor(self.limitNormalColor)
        }
    }

}
