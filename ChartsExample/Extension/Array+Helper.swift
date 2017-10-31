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
}

extension ChartDataEntry: Comparable {
    public static func <(lhs: ChartDataEntry, rhs: ChartDataEntry) -> Bool {
        return lhs.y < rhs.y
    }
}
