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
        
        vc = storyboard.instantiateViewControllerWithIdentifier("mainView") as ViewController
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
}
