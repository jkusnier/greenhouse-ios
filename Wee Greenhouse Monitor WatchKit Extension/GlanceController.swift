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

class GlanceController: WKInterfaceController {

    @IBOutlet weak var temperatureLabel: WKInterfaceLabel!
    @IBOutlet weak var lastUpdated: WKInterfaceLabel!

    var limitLow: Double = 38
    var limitHigh: Double = 85
    
    let limitLowColor = UIColor(red: 132/255, green: 183/255, blue: 255/255, alpha: 1) //UIColor.blueColor()
    let limitHighColor = UIColor(red: 237/255, green: 88/255, blue: 141/255, alpha: 1) //UIColor.redColor()
    let limitNormalColor = UIColor(red: 188/255, green: 226/255, blue: 158/255, alpha: 1) //UIColor.greenColor()
    
    var deviceId = "50ff6c065067545628550887"
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
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

        let ghApi = GreenhouseAPI()
        ghApi.refreshData(self.deviceId,
            failure: { error in
            }, success: {
                if let temperature = ghApi.temperature() {
                    tempString = String(format: "%.1f°", temperature)
                    self.setBackgroundColor(temperature)
                }
                
                if let publishedAt = ghApi.publishedAt() {
                    self.lastUpdated.setText(publishedAt.relativeDateFormat())
                }
            }
        )
        
        self.temperatureLabel.setText(tempString)
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
