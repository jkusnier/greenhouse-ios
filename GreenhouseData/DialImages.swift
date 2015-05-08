//
//  DialImages.swift
//  Wee Greenhouse Monitor
//
//  Created by Jason Kusnier on 3/28/15.
//  Copyright (c) 2015 Jason Kusnier. All rights reserved.
//

import Foundation

public class DialImages {
    
    let normalImagePrefix = "green-dial-outer-"
    let lowImagePrefix = "blue-dial-outer-"
    let highImagePrefix = "red-dial-outer-"
    
    var limitLow: Double = 38.0
    var limitHigh: Double = 85.0
    
    var previousImageIndex = 0
    
    public init(limitLow: Double, limitHigh: Double) {
        self.limitLow = limitLow
        self.limitHigh = limitHigh
    }
    
    public func temperatureChangeAnimation(startingTemp: Double, stoppingTemp: Double) -> [UIImage] {
        var imageArray = [UIImage]()
        var isDone = false
        
        let getImageIndex = { (offset: Double) -> Int in
            return Int(offset * ((1 / (self.limitHigh - self.limitLow)) * 100))
        }
        
        let appendImage = { (i: Int, imagePrefix: String) -> () in
            let seq = String(format: "%03d", arguments: [i])
            let imageName = "\(imagePrefix)\(seq)"
            let image = UIImage(named: imageName, inBundle: NSBundle(forClass: DialImages.self), compatibleWithTraitCollection: nil)
            if let image = image {
                imageArray.append(image)
            }
        }
        
        let doLoop = { (startingAt: Int, stoppingAt: Int, goingUp: Bool, whileDoing: Int -> ()) -> () in
            if (goingUp) {
                for (var i=startingAt;i<=stoppingAt;i++) {
                    whileDoing(i)
                }
            } else {
                for (var i=startingAt;i>=stoppingAt;i--) {
                    whileDoing(i)
                }
            }
        }
        
        let completeLoop = { (shouldComplete: Bool, truePrevIndex: Int, falsePrevIdex: Int) -> () in
            if shouldComplete {
                isDone = true
                self.previousImageIndex = truePrevIndex
            } else {
                self.previousImageIndex = falsePrevIdex
            }
        }
        
        if stoppingTemp >= startingTemp { // Going Up
            if startingTemp < self.limitLow {
                // Load blue from previousTemp to 0 or tempDbl
                // If to tempDbl, isDone = true
                
                let imageIndex = getImageIndex(self.limitLow - stoppingTemp) + 1
                let imageMax = imageIndex < 0 ? 0 : imageIndex
                doLoop(self.previousImageIndex, imageMax, false, { i in appendImage(i, self.lowImagePrefix) })
                
                completeLoop(imageMax > 0, imageIndex, 0)
                println("Up -> Below Low")
            }
            if !isDone && startingTemp < self.limitHigh {
                // Load green from 0 to tempDbl or 100
                // If to tempDbl, isDone = true
                
                let imageIndex = getImageIndex(stoppingTemp - self.limitLow)
                let imageMax = imageIndex > 100 ? 100 : imageIndex
                doLoop(self.previousImageIndex, imageMax, true, { i in appendImage(i, self.normalImagePrefix) })
                
                completeLoop(imageMax < 100, imageIndex, 0)
                println("Up -> Normal")
            }
            if !isDone && stoppingTemp >= self.limitHigh {
                // Load red from 0 to tempDbl or 100
                
                let imageIndex = getImageIndex(stoppingTemp - self.limitHigh)
                let imageMax = imageIndex > 100 ? 100 : imageIndex
                doLoop(self.previousImageIndex, imageMax, true, { i in appendImage(i, self.highImagePrefix) })
                
                self.previousImageIndex = imageIndex
                println("Up -> Above High")
            }
        } else { // Going Down
            if startingTemp >= self.limitHigh {
                // Load read images from previousTemp to tempDbl or 0
                // If to tempDbl, isDone = true
                
                let imageIndex = getImageIndex(stoppingTemp - self.limitHigh)
                let imageMin = (stoppingTemp < self.limitHigh) ? 0 : imageIndex
                doLoop(self.previousImageIndex, imageMin, false, { i in appendImage(i, self.highImagePrefix) })
                
                completeLoop(imageMin > 0, imageIndex, 100)
                println("Down -> Above High")
            }
            if !isDone && startingTemp > self.limitLow {
                // Load green from previousTemp to tempDbl or 0
                // If to tempDbl, isDone = true
                
                let imageIndex = getImageIndex(stoppingTemp - self.limitLow)
                let imageMin = (stoppingTemp < self.limitLow) ? 0 : imageIndex
                doLoop(self.previousImageIndex, imageMin, false, { i in appendImage(i, self.normalImagePrefix) })
                
                completeLoop(imageMin > 0, imageIndex, 0)
                println("Down -> Normal")
            }
            if !isDone && stoppingTemp <= self.limitLow {
                // Load blue from 0 to tempDbl or 100
                
                let imageIndex = getImageIndex(self.limitLow - stoppingTemp) + 1
                let imageMax = imageIndex > 100 ? 100 : imageIndex
                doLoop(self.previousImageIndex, imageMax, true, { i in appendImage(i, self.lowImagePrefix) })
                
                self.previousImageIndex = imageIndex
                println("Down -> Below Low")
            }
        }
        
        if imageArray.count > 50 {
            imageArray = imageArray.filter { find(imageArray, $0)! % 2 == 0 }
        }

        return imageArray
    }
}