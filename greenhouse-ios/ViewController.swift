//
//  ViewController.swift
//  greenhouse-ios
//
//  Created by Jason Kusnier on 10/23/14.
//  Copyright (c) 2014 Jason Kusnier. All rights reserved.
//

import UIKit
import GreenhouseData
import XCGLogger

private var defaultsContext = 0

class ViewController: UIViewController {

    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var lastUpdatedLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var outsideTempLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    let log = XCGLogger.defaultInstance()
    
    var allLabels: [UILabel]?
    
    var deviceId = "50ff6c065067545628550887"
    let outsideUrl:NSURL = NSURL(string: "http://api.weecode.com/greenhouse/v1/weather/STATION-HERE/fahrenheit/now")!
    var mainTimer:NSTimer?
    
    let timeInterval:NSTimeInterval = 60 as NSTimeInterval
    
    var limitLow: Double = 38
    var limitHigh: Double = 85
    var zipCode: String?
    
    let limitLowColor = UIColor(red: 132/255, green: 183/255, blue: 255/255, alpha: 1) //UIColor.blueColor()
    let limitHighColor = UIColor(red: 237/255, green: 88/255, blue: 141/255, alpha: 1) //UIColor.redColor()
    let limitNormalColor = UIColor(red: 188/255, green: 226/255, blue: 158/255, alpha: 1) //UIColor.greenColor()
    
    var previousTemp : Double = 0

    lazy var di: DialImages = DialImages(limitLow: self.limitLow, limitHigh: self.limitHigh)
    
    @IBOutlet weak var dialImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        updateDefaults()        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateDefaults", name: NSUserDefaultsDidChangeNotification, object: nil)

        allLabels = [temperatureLabel, lastUpdatedLabel, humidityLabel, outsideTempLabel, titleLabel]
        
        mainTimer = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: Selector("updateTitle"), userInfo: nil, repeats: true)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "resetTimer:", name: NSSystemClockDidChangeNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "stopTimer", name: UIApplicationWillResignActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "resetTimer:", name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if defaults.stringForKey("zipCode") == nil {
            var alert = UIAlertController(title: "Zip Code", message: "For outside temperature", preferredStyle: .Alert)
            
            alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
                textField.keyboardType = UIKeyboardType.NumberPad
            })

            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
                let textField = alert.textFields![0] as! UITextField
                defaults.setValue(textField.text, forKey: "zipCode")
                defaults.synchronize()
                self.log.debug {
                    let zipCode = defaults.stringForKey("zipCode")
                    let match = textField.text == zipCode
                    return "Zip Code - Entered: \(textField.text), Saved: \(zipCode), Match: \(match)"
                }
            }))

            self.presentViewController(alert, animated: true, completion: nil)
        }
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
//    override func viewDidAppear(animated: Bool) {
//        // Default deviceId makes this flow impossible. Saving for future iteration.
//        var requestDeviceId = false
//        let defaults = NSUserDefaults.standardUserDefaults()
//        if let deviceId = defaults.valueForKey("deviceId") as? String {
//            if deviceId.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).isEmpty {
//                requestDeviceId = true
//            } else {
//                // Set up the device
//            }
//        } else {
//            requestDeviceId = true
//        }
//        
//        if requestDeviceId {
//            self.performSegueWithIdentifier("requestDeviceId", sender: self)
//        }
//    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let dest = segue.destinationViewController as? DeviceIdViewController {
            dest.delegateViewController = self
        }
    }

    func updateDefaults() {
        let defaults = NSUserDefaults.standardUserDefaults()
        self.limitLow = Double(defaults.floatForKey("lowTempAlert"))
        self.limitHigh = Double(defaults.floatForKey("highTempAlert"))
        if let zipCode = defaults.stringForKey("zipCode") {
            self.zipCode = zipCode
        }
        if let deviceId = defaults.stringForKey("deviceId") {
            if deviceId.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).isEmpty {
                defaults.removeObjectForKey("deviceId")
                defaults.synchronize()
            }
            
            if let deviceId = defaults.stringForKey("deviceId") {
                self.deviceId = deviceId
                updateTitle()
            } else {
                log.info("deviceId not found")
            }
        }
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
        let temperatureFmt = "%.1f°"
        let humdityFmt = "%d%%"
        let defaultTemp = "--°"
        let defaultHumidty = "---%"
        
        var tempString = defaultTemp
        var humidityString = defaultHumidty
        var tempDbl = 0.0

        
        let ghApi = GreenhouseAPI()
        ghApi.refreshData(self.deviceId,
            failure: { error in
            }, success: {
                if let temperature = ghApi.temperature() {
                    tempDbl = temperature
                    tempString = String(format: temperatureFmt, temperature)
                    self.setBackgroundColor(temperature)
                }
                
                if let humidity = ghApi.humidity() {
                    humidityString = String(format: humdityFmt, humidity)
                }
                
                if let publishedAt = ghApi.publishedAt() {
                    self.lastUpdatedLabel.text = publishedAt.relativeDateFormat()
                }
            }
        )

        temperatureLabel.text = tempString
        humidityLabel.text = humidityString
        
        var outsideTempString = defaultTemp
        
        if let zipCode = zipCode {
            let weatherApi = WeatherAPI()
            weatherApi.refreshData(zipCode,
                failure: { error in
                }, success: {
                    if let temperature = weatherApi.temperature() {
                        outsideTempString = String(format: temperatureFmt, temperature)
                    }
            })
        }

        outsideTempLabel.text = outsideTempString
        
        self.previousTemp = tempDbl
        let imageArray = self.di.temperatureChangeAnimation(self.previousTemp, stoppingTemp: tempDbl)
        if imageArray.count > 0 {
            self.dialImage.animationImages = imageArray
            self.dialImage.image = imageArray.last
            self.dialImage.animationRepeatCount = 1
            self.dialImage.animationDuration = imageArray.count > 10 ? 1.0 : 2.0
            self.dialImage.startAnimating()
        }
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
    
    func closeModal() {
        self.dismissViewControllerAnimated(true, completion: nil);
    }
}

