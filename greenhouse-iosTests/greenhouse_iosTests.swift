//
//  greenhouse_iosTests.swift
//  greenhouse-iosTests
//
//  Created by Jason Kusnier on 10/23/14.
//  Copyright (c) 2014 Jason Kusnier. All rights reserved.
//

import UIKit
import XCTest

class greenhouse_iosTests: XCTestCase {
    
    var vc : ViewController!
    
    override func setUp() {
        super.setUp()
        
        var storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle(forClass: self.dynamicType))
        
        vc = storyboard.instantiateViewControllerWithIdentifier("mainView") as! ViewController
        XCTAssertNotNil(vc, "Test Not Configured Properly")
        vc.loadView()
        
        XCTAssert(true, "Pass")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTemperatureLabel() {
        if let m_vc = vc {
            var temperatureLabel = m_vc.temperatureLabel
            XCTAssertNotNil(temperatureLabel, "Temperature Label Not Present")
            
            XCTAssertNotEqual(temperatureLabel.text!, "", "Temperature Label Not Set")
        } else {
            XCTFail("ViewController not loaded")
        }
    }

    func testLastUpdatedLabel() {
        if let m_vc = vc {
            var lastUpdatedLabel = m_vc.lastUpdatedLabel
            XCTAssertNotNil(lastUpdatedLabel, "Last Updated Label Not Present")
            
            XCTAssertNotEqual(lastUpdatedLabel.text!, "", "Last Updated Label Not Set")
        } else {
            XCTFail("ViewController not loaded")
        }
    }

    func testHumidityLabel() {
        if let m_vc = vc {
            var humidityLabel = m_vc.humidityLabel
            XCTAssertNotNil(humidityLabel, "Humidity Label Not Present")
            
            XCTAssertNotEqual(humidityLabel.text!, "", "Humidity Label Not Set")
        } else {
            XCTFail("ViewController not loaded")
        }
    }

    func testOutsideTempLabel() {
        if let m_vc = vc {
            var outsideTempLabel = m_vc.outsideTempLabel
            XCTAssertNotNil(outsideTempLabel, "Outside Temp Label Not Present")
            
            XCTAssertNotEqual(outsideTempLabel.text!, "", "Outside Temp Label Not Set")
        } else {
            XCTFail("ViewController not loaded")
        }
    }
    
    func testMainTimer() {
        if let timer = vc.mainTimer {
            XCTAssertNotNil(timer, "Timer Not Created")
            
            XCTAssertEqual(timer.timeInterval, vc.timeInterval, "Time Interval Different")
            XCTAssertTrue(timer.valid, "Timer is not valid")
        }
    }
    
    func testBackgroundColor() {
        if let m_vc = vc {
            m_vc.setBackgroundColor(m_vc.limitLow)
            XCTAssertEqual(m_vc.limitLowColor, m_vc.view.backgroundColor!, "Cold Background Color Failed")
            
            m_vc.setBackgroundColor(m_vc.limitLow - 10)
            XCTAssertEqual(m_vc.limitLowColor, m_vc.view.backgroundColor!, "Cold Background Color Failed")

            m_vc.setBackgroundColor(m_vc.limitHigh)
            XCTAssertEqual(m_vc.limitHighColor, m_vc.view.backgroundColor!, "Hot Background Color Failed")
            
            m_vc.setBackgroundColor(m_vc.limitHigh + 10)
            XCTAssertEqual(m_vc.limitHighColor, m_vc.view.backgroundColor!, "Hot Background Color Failed")
            
            m_vc.setBackgroundColor(m_vc.limitHigh - 10)
            XCTAssertEqual(m_vc.limitNormalColor, m_vc.view.backgroundColor!, "Normal Background Color Failed")
            
            m_vc.setBackgroundColor(m_vc.limitLow + 10)
            XCTAssertEqual(m_vc.limitNormalColor, m_vc.view.backgroundColor!, "Normal Background Color Failed")
        }
    }
}
