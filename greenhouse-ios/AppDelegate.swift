//
//  AppDelegate.swift
//  greenhouse-ios
//
//  Created by Jason Kusnier on 10/23/14.
//  Copyright (c) 2014 Jason Kusnier. All rights reserved.
//

import UIKit
import XCGLogger

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let log = XCGLogger.defaultInstance()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        #if DEBUG
            log.setup(logLevel: .Debug, showLogLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: nil)
        #else
            log.setup(logLevel: .Severe, showLogLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: nil)
        #endif
        
        UIDevice.currentDevice().batteryMonitoringEnabled = true
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "_batteryStateChanged", name: UIDeviceBatteryStateDidChangeNotification, object: nil)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let defaultsDict = ["lowTempAlert": 38, "highTempAlert": 85, "deviceId": "50ff6c065067545628550887"]
        defaults.registerDefaults(defaultsDict)
        
        log.debug("application launched")
        
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

