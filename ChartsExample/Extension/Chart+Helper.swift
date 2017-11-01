//
//  ChartDataEntry+Helper.swift
//  ChartsExample
//
//  Created by Vincent Ngo on 11/1/17.
//  Copyright © 2017 Vincent Ngo. All rights reserved.
//

import UIKit
import Charts

extension ChartDataEntry {
    var date: Date? {
        return Date(timeIntervalSinceReferenceDate: self.x * 60)
    }
}

extension ChartDataEntry: Comparable {
    public static func <(lhs: ChartDataEntry, rhs: ChartDataEntry) -> Bool {
        return lhs.y < rhs.y
    }
}

extension BarLineScatterCandleBubbleRenderer {
    /// Calculates and returns the x-bounds for the given DataSet in terms of index in their values array.
    /// This includes minimum and maximum visible x, as well as range.
    func xBounds(chart: BarLineScatterCandleBubbleChartDataProvider,
                 dataSet: IBarLineScatterCandleBubbleChartDataSet,
                 animator: Animator?) -> XBounds {
        return XBounds(chart: chart, dataSet: dataSet, animator: animator)
    }
    
    /// Checks if the provided entry object is in bounds for drawing considering the current animation phase.
    func isInBoundsX(entry e: ChartDataEntry, dataSet: IBarLineScatterCandleBubbleChartDataSet) -> Bool {
        let entryIndex = dataSet.entryIndex(entry: e)
        
        if Double(entryIndex) >= Double(dataSet.entryCount) * (animator?.phaseX ?? 1.0) {
            return false
        } else {
            return true
        }
    }
}
