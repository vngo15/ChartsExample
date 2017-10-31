//
//  InsightXAxisRenderer.swift
//  ChartsExample
//
//  Created by Vincent Ngo on 10/23/17.
//  Copyright © 2017 Vincent Ngo. All rights reserved.
//  The date value is based on UTC time zone
//

import UIKit
import Charts
class InsightXAxisRenderer: XAxisRenderer {
    var timeZone: TimeZone = TimeZone.current
    
    override func drawGridLine(context: CGContext, x: CGFloat, y: CGFloat) {
        guard let viewPortHandler = self.viewPortHandler else { return }
        
        if x >= viewPortHandler.offsetLeft && x <= viewPortHandler.chartWidth {
            context.beginPath()
            context.move(to: CGPoint(x: x, y: viewPortHandler.contentTop + K.XAxis.gridLineHeight))
            context.addLine(to: CGPoint(x: x, y: viewPortHandler.contentTop))
            context.strokePath()
        }
    }
    
    override func computeAxisValues(min: Double, max: Double) {
        guard let axis = self.axis else { return }
        
        let yMin = min
        let yMax = max
        
        let range = abs(yMax - yMin)
        let labelCount: Int = Int(range) / (86400 / 60)
        
        if labelCount == 0 || range <= 0 || range.isInfinite {
            axis.entries = [Double]()
            axis.centeredEntries = [Double]()
            return
        }
        
        // Find out how much spacing (in y value space) between axis values
        let rawInterval = range / Double(labelCount)
        var interval = roundToNextSignificant(number: Double(rawInterval))
        
        // If granularity is enabled, then do not allow the interval to go below specified granularity.
        // This is used to avoid repeated values when rounding values for display.
        if axis.granularityEnabled {
            interval = axis.granularity
        }
        
        // Normalize interval
        let intervalMagnitude = roundToNextSignificant(number: pow(10.0, Double(Int(log10(interval)))))
        let intervalSigDigit = Int(interval / intervalMagnitude)
        if intervalSigDigit > 5 {
            // Use one order of magnitude higher, to avoid intervals like 0.9 or 90
            interval = floor(10.0 * Double(intervalMagnitude))
        }
        
        var n = axis.centerAxisLabelsEnabled ? 1 : 0
        // Fixed timezone with offset
        let offset = Double(timeZone.secondsFromGMT()) / 60.0
        
        var first = interval == 0.0 ? 0.0 : ceil(yMin / interval) * interval - offset
        
        if axis.centerAxisLabelsEnabled {
            first -= interval
        }
        
        let last = interval == 0.0 ? 0.0 : nextUp(floor(yMax / interval) * interval) - offset
        
        if interval != 0.0 && last != first {
            for _ in stride(from: first, through: last, by: interval) {
                n += 1
            }
        }
        
        // Ensure stops contains at least n elements.
        axis.entries.removeAll(keepingCapacity: true)
        axis.entries.reserveCapacity(labelCount)
        
        var f = first
        var i = 0
        while i < n {
            if f == 0.0 {
                // Fix for IEEE negative zero case (Where value == -0.0, and 0.0 == -0.0)
                f = 0.0
            }
            
            axis.entries.append(Double(f))
            
            f += interval
            i += 1
        }
        
        
        // set decimals
        if interval < 1 {
            axis.decimals = Int(ceil(-log10(interval)))
        } else {
            axis.decimals = 0
        }
        
        if axis.centerAxisLabelsEnabled {
            axis.centeredEntries.reserveCapacity(n)
            axis.centeredEntries.removeAll()
            
            let offset: Double = interval / 2.0
            
            for i in 0 ..< n {
                axis.centeredEntries.append(axis.entries[i] + offset)
            }
        }
        computeSize()
    }
}

fileprivate func roundToNextSignificant(number: Double) -> Double {
    if number.isInfinite || number.isNaN || number == 0 {
        return number
    }
    
    let d = ceil(log10(number < 0.0 ? -number : number))
    let pw = 1 - Int(d)
    let magnitude = pow(Double(10.0), Double(pw))
    let shifted = round(number * magnitude)
    return shifted / magnitude
}

fileprivate func nextUp(_ number: Double) -> Double {
    if number.isInfinite || number.isNaN {
        return number
    } else {
        return number + Double.ulpOfOne
    }
}

