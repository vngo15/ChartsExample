//
//  DateAxisFormatter.swift
//  ChartsExample
//
//  Created by Vincent Ngo on 10/19/17.
//  Copyright © 2017 Vincent Ngo. All rights reserved.
//

import UIKit
import Charts
class DateAxisFormatter: NSObject {
    weak var chart: ChartViewBase?
    lazy private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("M/dd")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
    
    init(chart: ChartViewBase?) {
        super.init()
        self.chart = chart
    }
}

extension DateAxisFormatter: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let date = Date(timeIntervalSinceReferenceDate: value * 60)
        if date.isToday {
            return "Today"
        } else {
            return dateFormatter.string(from: date)
        }
    }
}
