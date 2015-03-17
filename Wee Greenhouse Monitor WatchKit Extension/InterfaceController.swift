//
//  InterfaceController.swift
//  Wee Greenhouse Monitor WatchKit Extension
//
//  Created by Jason Kusnier on 3/8/15.
//  Copyright (c) 2015 Jason Kusnier. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    @IBOutlet weak var mainGroup: WKInterfaceGroup!
    @IBOutlet weak var temperatureLabel: WKInterfaceLabel!
    @IBOutlet weak var lastUpdated: WKInterfaceLabel!

    var mainTimer:NSTimer?
    
    let timeInterval:NSTimeInterval = 60 as NSTimeInterval
    
    var limitLow: Double = 38
    var limitHigh: Double = 85
    
    let limitLowColor = UIColor(red: 132/255, green: 183/255, blue: 255/255, alpha: 1) //UIColor.blueColor()
    let limitHighColor = UIColor(red: 237/255, green: 88/255, blue: 141/255, alpha: 1) //UIColor.redColor()
    let limitNormalColor = UIColor(red: 188/255, green: 226/255, blue: 158/255, alpha: 1) //UIColor.greenColor()

    let normalImagePrefix = "green-dial-outer-"
    let lowImagePrefix = "blue-dial-outer-"
    let highImagePrefix = "red-dial-outer-"
    var currentImageIndex = 1
    var previousTemp : Double = 0

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        mainTimer = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: Selector("updateTitle"), userInfo: nil, repeats: true)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "resetTimer:", name: NSSystemClockDidChangeNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "stopTimer", name: UIApplicationWillResignActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "resetTimer:", name: UIApplicationWillEnterForegroundNotification, object: nil)
        
        // Configure interface objects here.
        updateTitle()
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
        var tempDbl = 0.0
        var humidityString = "---%"
        if let envUrl = NSURL(string: "http://api.weecode.com/greenhouse/v1/devices/50ff6c065067545628550887/environment") {
            let jsonData = NSData(contentsOfURL: envUrl)
            if let jsonData = jsonData? {
                var error: NSError?
                let jsonDict = NSJSONSerialization.JSONObjectWithData(jsonData, options: nil, error: &error) as NSDictionary
                
                
                if (error == nil) {
                    tempString = String(format: "%.1f°", jsonDict["fahrenheit"] as Double)
                    tempDbl = jsonDict["fahrenheit"] as Double
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
        
        let imageIndex = Int(((tempDbl - self.limitLow) / (self.limitHigh - self.limitLow)) * 100)
        
        var isDone = false
        var imageArray = [UIImage]()
        if imageIndex >= self.currentImageIndex { // Going Up
            if self.previousTemp <= self.limitLow {
                // Load blue from previousTemp to 0 or tempDbl
                // If to tempDbl, isDone = true
            }
            if !isDone && self.previousTemp < self.limitHigh {
                // Load green from 0 to tempDbl or 100
                // If to tempDbl, isDone = true
                
                // FIXME base this on a function to get the image step/starting point
                for (var i=self.currentImageIndex;i<=imageIndex;i++) {
                    let seq = String(format: "%03d", arguments: [i])
                    let imageName = "\(self.normalImagePrefix)\(seq)"
                    let image = UIImage(named: imageName)
                    if let image = image {
                        imageArray.append(image)
                    }
                }
            }
            if !isDone && tempDbl >= self.limitHigh {
                // Load red from 0 to tempDbl or 100
            }
        } else { // Going Down
            if self.previousTemp >= self.limitHigh {
                // Load read images from previousTemp to tempDbl or 0
                // If to tempDbl, isDone = true
            }
            if !isDone && self.previousTemp > self.limitLow {
                // Load green from previousTemp to tempDbl or 0
                // If to tempDbl, isDone = true
                
                // FIXME base this on a function to get the image step/starting point
                for (var i=self.currentImageIndex;i>=imageIndex;i--) {
                    let seq = String(format: "%03d", arguments: [i])
                    let imageName = "\(self.normalImagePrefix)\(seq)"
                    let image = UIImage(named: imageName)
                    if let image = image {
                        imageArray.append(image)
                    }
                }
            }
            if !isDone && self.previousTemp <= self.limitLow {
                // Load blue from 0 to tempDbl or 100
            }
        }
        
        self.previousTemp = tempDbl
        self.currentImageIndex = imageIndex
        
        let dialImage = UIImage.animatedImageWithImages(imageArray, duration: 1.0)

        self.mainGroup.setBackgroundImage(dialImage)
        let tInterval = imageArray.count > 10 ? 3.0 : 1.0
        self.mainGroup.startAnimatingWithImagesInRange(NSRange(location: 0, length: imageArray.count), duration: tInterval, repeatCount: 1)

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
    
    func resetTimer(aNotification: NSNotification) {
        mainTimer?.invalidate()
        mainTimer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: Selector("updateTitle"), userInfo: nil, repeats: true)
        updateTitle()
    }
    
    func stopTimer() {
        mainTimer?.invalidate()
    }
}
