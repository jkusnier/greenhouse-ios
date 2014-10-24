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
    
    let url:NSURL = NSURL(string: "http://api.weecode.com/greenhouse/v1/devices/50ff6c065067545628550887/environment")!
    var mainTimer:NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainTimer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: Selector("updateTitle"), userInfo: nil, repeats: true)
        
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
        var error: NSError?
        let jsonData = NSData(contentsOfURL: url)
        if (jsonData != nil) {
            let jsonDict = NSJSONSerialization.JSONObjectWithData(jsonData!, options: nil, error: &error) as NSDictionary
            
            
            if (error == nil) {
                tempString = String(format: "%.1f°", jsonDict["fahrenheit"] as Double)
                lastUpdatedLabel.text = NSDate(dateString: jsonDict["published_at"] as String).localFormat()
            }
        }
        temperatureLabel.text = tempString
    }
}

