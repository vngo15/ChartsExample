//
//  Array+Helper.swift
//  ChartsExample
//
//  Created by Vincent Ngo on 10/23/17.
//  Copyright © 2017 Vincent Ngo. All rights reserved.
//

import UIKit
import Charts

extension Array where Element == ChartDataEntry {
    /// Returns the sum of all elements in the array
    var total: Double {
        return reduce(0, { (r, e) -> Double in
            return r + e.y
        })
    }
    /// Returns the average of all elements in the array
    var average: Double {
        return isEmpty ? 0 : total / Double(count)
    }
    
    func sameDayEntries<T: ChartDataEntry>(fromEntry e: T) -> [T] {
        var entries = [T]()
        let calendar = Calendar(identifier: .gregorian)
        for entry in self {
            if entry != e, let entry = entry as? T, let day = entry.date, let rday = e.date, calendar.isDate(day, inSameDayAs: rday) {
                entries.append(entry)
            }
        }
        return entries
    }
}

extension Array where Element == WaterIntakeChartDataEntry {
    func totalWaterIntake(forTime x: Double) -> Int {
        var total = 0
        let calendar = Calendar(identifier: .gregorian)
        let rday = Date(timeIntervalSinceReferenceDate: x * 60)
        for entry in self {
            if let day = entry.date, calendar.isDate(day, inSameDayAs: rday) {
                total += entry.count
            }
        }
        return total
    }
}
