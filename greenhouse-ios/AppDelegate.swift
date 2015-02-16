//
//  AppDelegate.swift
//  greenhouse-ios
//
//  Created by Jason Kusnier on 10/23/14.
//  Copyright (c) 2014 Jason Kusnier. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        UIDevice.currentDevice().batteryMonitoringEnabled = true
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "_batteryStateChanged", name: UIDeviceBatteryStateDidChangeNotification, object: nil)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let defaultsDict = ["lowTempAlert": 38, "highTempAlert": 85]
        defaults.registerDefaults(defaultsDict)
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
    }

    func applicationDidEnterBackground(application: UIApplication) {
    }

    func applicationWillEnterForeground(application: UIApplication) {
    }

    func applicationDidBecomeActive(application: UIApplication) {
        self._batteryStateChanged()
    }

    func applicationWillTerminate(application: UIApplication) {
    }
    
    func _batteryStateChanged() {
        // If plugged in, no idle timeout
        let currentState = UIDevice.currentDevice().batteryState
        if (currentState == UIDeviceBatteryState.Charging || currentState == UIDeviceBatteryState.Full) {
            UIApplication.sharedApplication().idleTimerDisabled = true
        } else {
            UIApplication.sharedApplication().idleTimerDisabled = false
        }
    }
}

