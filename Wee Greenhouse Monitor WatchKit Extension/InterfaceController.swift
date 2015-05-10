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
    
    let animationThreshold = 10
    let animationFast = 3.0
    let animationSlow = 1.0
    
    let limitLowColor = UIColor(red: 132/255, green: 183/255, blue: 255/255, alpha: 1) //UIColor.blueColor()
    let limitHighColor = UIColor(red: 237/255, green: 88/255, blue: 141/255, alpha: 1) //UIColor.redColor()
    let limitNormalColor = UIColor(red: 188/255, green: 226/255, blue: 158/255, alpha: 1) //UIColor.greenColor()

    let normalImagePrefix = "green-dial-outer-"
    let lowImagePrefix = "blue-dial-outer-"
    let highImagePrefix = "red-dial-outer-"

    var previousTemp : Double = 0
    
    lazy var di: DialImages = DialImages(limitLow: self.limitLow, limitHigh: self.limitHigh)
    
    var deviceId = "50ff6c065067545628550887"

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        self.previousTemp = self.limitLow
        
        mainTimer = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: Selector("updateTitle"), userInfo: nil, repeats: true)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "resetTimer:", name: NSSystemClockDidChangeNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "stopTimer", name: UIApplicationWillResignActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "resetTimer:", name: UIApplicationWillEnterForegroundNotification, object: nil)
        
        self.setTitle("Greenhouse")
        
        // Configure interface objects here.
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        updateTitle()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func updateTitle() {
        var tempString = "--°"
        var tempDbl = 0.0
        
        let ghApi = GreenhouseAPI()
        ghApi.refreshData(self.deviceId,
            failure: { error in
            }, success: {
                if let temperature = ghApi.temperature() {
                    tempDbl = temperature
                    tempString = String(format: "%.1f°", temperature)
                    self.setBackgroundColor(temperature)
                }

                if let publishedAt = ghApi.publishedAt() {
                    self.lastUpdated.setText(publishedAt.relativeDateFormat())
                }
            }
        )
        
        self.temperatureLabel.setText(tempString)

        var imageArray = self.di.temperatureChangeAnimation(self.previousTemp, stoppingTemp: tempDbl)
        self.previousTemp = tempDbl
        
        let dialImage = UIImage.animatedImageWithImages(imageArray, duration: 1.0)

        self.mainGroup.setBackgroundImage(dialImage)
        let tInterval = imageArray.count > self.animationThreshold ? self.animationSlow : self.animationFast
        self.mainGroup.startAnimatingWithImagesInRange(NSRange(location: 0, length: imageArray.count), duration: tInterval, repeatCount: 1)
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
    
    @IBAction func refreshTemperature() {
        updateTitle()
    }
}
