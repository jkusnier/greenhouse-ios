//
//  ViewController.swift
//  greenhouse-ios
//
//  Created by Jason Kusnier on 10/23/14.
//  Copyright (c) 2014 Jason Kusnier. All rights reserved.
//

import UIKit

private var defaultsContext = 0

class ViewController: UIViewController {

    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var lastUpdatedLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var outsideTempLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    var allLabels: [UILabel]?
    
    let envUrl:NSURL = NSURL(string: "http://api.weecode.com/greenhouse/v1/devices/50ff6c065067545628550887/environment")!
    let outsideUrl:NSURL = NSURL(string: "http://api.weecode.com/greenhouse/v1/weather/STATION-HERE/fahrenheit/now")!
    var mainTimer:NSTimer?
    
    let timeInterval:NSTimeInterval = 60 as NSTimeInterval
    
    var limitLow: Double = 38
    var limitHigh: Double = 85
    
    let limitLowColor = UIColor(red: 132/255, green: 183/255, blue: 255/255, alpha: 1) //UIColor.blueColor()
    let limitHighColor = UIColor(red: 237/255, green: 88/255, blue: 141/255, alpha: 1) //UIColor.redColor()
    let limitNormalColor = UIColor(red: 188/255, green: 226/255, blue: 158/255, alpha: 1) //UIColor.greenColor()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateDefaults()        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateDefaults", name: NSUserDefaultsDidChangeNotification, object: nil)

        allLabels = [temperatureLabel, lastUpdatedLabel, humidityLabel, outsideTempLabel, titleLabel]
        
        mainTimer = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: Selector("updateTitle"), userInfo: nil, repeats: true)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "resetTimer:", name: NSSystemClockDidChangeNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "stopTimer", name: UIApplicationWillResignActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "resetTimer:", name: UIApplicationWillEnterForegroundNotification, object: nil)
        
        updateTitle()
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func updateDefaults() {
        let defaults = NSUserDefaults.standardUserDefaults()
        self.limitLow = Double(defaults.floatForKey("lowTempAlert"))
        self.limitHigh = Double(defaults.floatForKey("highTempAlert"))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func resetTimer(aNotification: NSNotification) {
        mainTimer?.invalidate()
        mainTimer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: Selector("updateTitle"), userInfo: nil, repeats: true)
        updateTitle()
    }
    
    func stopTimer() {
        mainTimer?.invalidate()
    }

    func updateTitle() {
        var tempString = "--°"
        var humidityString = "---%"
        let jsonData = NSData(contentsOfURL: envUrl)
        if let jsonData = jsonData? {
            var error: NSError?
            let jsonDict = NSJSONSerialization.JSONObjectWithData(jsonData, options: nil, error: &error) as NSDictionary
            
            
            if (error == nil) {
                tempString = String(format: "%.1f°", jsonDict["fahrenheit"] as Double)
                setBackgroundColor(jsonDict["fahrenheit"] as Double)
                humidityString = String(format: "%d%%", jsonDict["humidity"] as Int)
                lastUpdatedLabel.text = NSDate(dateString: jsonDict["published_at"] as String).localFormat()
            }
        }
        temperatureLabel.text = tempString
        humidityLabel.text = humidityString
        
        var outsideTempString = "--°"
        let jsonData2 = NSData(contentsOfURL: outsideUrl)
        if let jsonData2 = jsonData2? {
            var error: NSError?
            let jsonDict = NSJSONSerialization.JSONObjectWithData(jsonData2, options: nil, error: &error) as NSDictionary
            
            
            if (error == nil) {
                outsideTempString = String(format: "%.1f°", jsonDict["temp_f"] as Double)
            }
        }
        
        outsideTempLabel.text = outsideTempString
    }
    
    func setBackgroundColor(temperature: Double) {
        if (temperature <= limitLow) {
            self.view.backgroundColor = limitLowColor
            setLabelColor(UIColor.whiteColor())
        } else if (temperature >= limitHigh) {
            self.view.backgroundColor = limitHighColor
            setLabelColor(UIColor.whiteColor())
        } else {
            self.view.backgroundColor = limitNormalColor
            setLabelColor(UIColor.blackColor())
        }
    }
    
    func setLabelColor(color: UIColor) {
        if let labels = allLabels {
            for label: UILabel in labels {
                label.textColor = color
            }
        }
    }
}

