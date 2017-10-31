//
//  ValueFormatter.swift
//  ChartsExample
//
//  Created by Vincent Ngo on 10/23/17.
//  Copyright © 2017 Vincent Ngo. All rights reserved.
//

import UIKit
import Charts
class ValueFormatter: NSObject {
    weak var chart: ChartViewBase?
    
    init(chart: ChartViewBase?) {
        super.init()
        self.chart = chart
    }
}

extension ValueFormatter: IValueFormatter {
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        if let dataSets = chart?.data?.dataSets, dataSets.count > 0, let set = dataSets[0] as? LineChartDataSet {
            if let max = set.values.max(), max == entry {
                return String(format: "High: %1.0f%%", arguments: [value])
            } else if let min = set.values.min(), min == entry {
                return String(format: "Low: %1.0f%%", arguments: [value])
            }
        }
        return ""
    }
}
