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

    var limitLow: Double = 38
    var limitHigh: Double = 85
    
    let limitLowColor = UIColor(red: 132/255, green: 183/255, blue: 255/255, alpha: 1) //UIColor.blueColor()
    let limitHighColor = UIColor(red: 237/255, green: 88/255, blue: 141/255, alpha: 1) //UIColor.redColor()
    let limitNormalColor = UIColor(red: 188/255, green: 226/255, blue: 158/255, alpha: 1) //UIColor.greenColor()
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
