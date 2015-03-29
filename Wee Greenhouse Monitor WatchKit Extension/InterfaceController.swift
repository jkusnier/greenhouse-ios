//
//  InterfaceController.swift
//  Wee Greenhouse Monitor WatchKit Extension
//
//  Created by Jason Kusnier on 3/8/15.
//  Copyright (c) 2015 Jason Kusnier. All rights reserved.
//

import WatchKit
import Foundation
import GreenhouseData

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

    var previousTemp : Double = 0
    var previousImageIndex = 0

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        self.previousTemp = self.limitLow
        
        mainTimer = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: Selector("updateTitle"), userInfo: nil, repeats: true)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "resetTimer:", name: NSSystemClockDidChangeNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "stopTimer", name: UIApplicationWillResignActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "resetTimer:", name: UIApplicationWillEnterForegroundNotification, object: nil)
        
        self.setTitle("Greenhouse")
        
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

        let getImageIndex = { (offset: Double) -> Int in
            return Int(offset * ((1 / (self.limitHigh - self.limitLow)) * 100))
        }

        var isDone = false
        var imageArray = [UIImage]()
        DialImages.temperatureChangeAnimation(123.0, stoppingTemp: 123.0)
        
        let appendImage = { (i: Int, imagePrefix: String) -> () in
            let seq = String(format: "%03d", arguments: [i])
            let imageName = "\(imagePrefix)\(seq)"
            let image = UIImage(named: imageName)
            if let image = image {
                imageArray.append(image)
            }
        }
        
        let doLoop = { (startingAt: Int, stoppingAt: Int, goingUp: Bool, whileDoing: Int -> ()) -> () in
            if (goingUp) {
                for (var i=startingAt;i<=stoppingAt;i++) {
                    whileDoing(i)
                }
            } else {
                for (var i=startingAt;i>=stoppingAt;i--) {
                    whileDoing(i)
                }
            }
        }
        
        let completeLoop = { (shouldComplete: Bool, truePrevIndex: Int, falsePrevIdex: Int) -> () in
            if shouldComplete {
                isDone = true
                self.previousImageIndex = truePrevIndex
            } else {
                self.previousImageIndex = falsePrevIdex
            }
        }

        if tempDbl >= self.previousTemp { // Going Up
            if self.previousTemp < self.limitLow {
                // Load blue from previousTemp to 0 or tempDbl
                // If to tempDbl, isDone = true
                
                let imageIndex = getImageIndex(self.limitLow - tempDbl) + 1
                let imageMax = imageIndex < 0 ? 0 : imageIndex
                doLoop(self.previousImageIndex, imageMax, false, { i in appendImage(i, self.lowImagePrefix) })
                
                completeLoop(imageMax > 0, imageIndex, 0)
                println("Up -> Below Low")
            }
            if !isDone && self.previousTemp < self.limitHigh {
                // Load green from 0 to tempDbl or 100
                // If to tempDbl, isDone = true
                
                let imageIndex = getImageIndex(tempDbl - self.limitLow)
                let imageMax = imageIndex > 100 ? 100 : imageIndex
                doLoop(self.previousImageIndex, imageMax, true, { i in appendImage(i, self.normalImagePrefix) })
                
                completeLoop(imageMax < 100, imageIndex, 0)
                println("Up -> Normal")
            }
            if !isDone && tempDbl >= self.limitHigh {
                // Load red from 0 to tempDbl or 100
                
                let imageIndex = getImageIndex(tempDbl - self.limitHigh)
                let imageMax = imageIndex > 100 ? 100 : imageIndex
                doLoop(self.previousImageIndex, imageMax, true, { i in appendImage(i, self.highImagePrefix) })
                
                self.previousImageIndex = imageIndex
                println("Up -> Above High")
            }
        } else { // Going Down
            if self.previousTemp >= self.limitHigh {
                // Load read images from previousTemp to tempDbl or 0
                // If to tempDbl, isDone = true
                
                let imageIndex = getImageIndex(tempDbl - self.limitHigh)
                let imageMin = (tempDbl < self.limitHigh) ? 0 : imageIndex
                doLoop(self.previousImageIndex, imageMin, false, { i in appendImage(i, self.highImagePrefix) })
                
                completeLoop(imageMin > 0, imageIndex, 100)
                println("Down -> Above High")
            }
            if !isDone && self.previousTemp > self.limitLow {
                // Load green from previousTemp to tempDbl or 0
                // If to tempDbl, isDone = true
                
                let imageIndex = getImageIndex(tempDbl - self.limitLow)
                let imageMin = (tempDbl < self.limitLow) ? 0 : imageIndex
                doLoop(self.previousImageIndex, imageMin, false, { i in appendImage(i, self.normalImagePrefix) })
                
                completeLoop(imageMin > 0, imageIndex, 0)
                println("Down -> Normal")
            }
            if !isDone && tempDbl <= self.limitLow {
                // Load blue from 0 to tempDbl or 100
                
                let imageIndex = getImageIndex(self.limitLow - tempDbl) + 1
                let imageMax = imageIndex > 100 ? 100 : imageIndex
                doLoop(self.previousImageIndex, imageMax, true, { i in appendImage(i, self.lowImagePrefix) })
                
                self.previousImageIndex = imageIndex
                println("Down -> Below Low")
            }
        }
        
        self.previousTemp = tempDbl
        
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
