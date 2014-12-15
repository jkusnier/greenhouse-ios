//
//  ViewController.swift
//  greenhouse-ios
//
//  Created by Jason Kusnier on 10/23/14.
//  Copyright (c) 2014 Jason Kusnier. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var lastUpdatedLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var outsideTempLabel: UILabel!
    
    let envUrl:NSURL = NSURL(string: "http://api.weecode.com/greenhouse/v1/devices/50ff6c065067545628550887/environment")!
    let outsideUrl:NSURL = NSURL(string: "http://api.weecode.com/greenhouse/v1//weather/STATION-HERE/fahrenheit/now")!
    var mainTimer:NSTimer?
    
    let timeInterval:NSTimeInterval = 60 as NSTimeInterval
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainTimer = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: Selector("updateTitle"), userInfo: nil, repeats: true)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "resetTimer:", name: NSSystemClockDidChangeNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "stopTimer", name: UIApplicationWillResignActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "resetTimer:", name: UIApplicationWillEnterForegroundNotification, object: nil)
        
        updateTitle()
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
        var error: NSError?
        let jsonData = NSData(contentsOfURL: envUrl)
        if (jsonData != nil) {
            let jsonDict = NSJSONSerialization.JSONObjectWithData(jsonData!, options: nil, error: &error) as NSDictionary
            
            
            if (error == nil) {
                tempString = String(format: "%.1f°", jsonDict["fahrenheit"] as Double)
                humidityString = String(format: "%d%%", jsonDict["humidity"] as Int)
                lastUpdatedLabel.text = NSDate(dateString: jsonDict["published_at"] as String).localFormat()
            }
        }
        temperatureLabel.text = tempString
        humidityLabel.text = humidityString
        
        var outsideTempString = "--°"
        let jsonData2 = NSData(contentsOfURL: outsideUrl)
        if (jsonData2 != nil) {
            let jsonDict = NSJSONSerialization.JSONObjectWithData(jsonData2!, options: nil, error: &error) as NSDictionary
            
            
            if (error == nil) {
                outsideTempString = String(format: "%.1f°", jsonDict["temp_f"] as Double)
            }
        }
        
        outsideTempLabel.text = outsideTempString
    }
}

