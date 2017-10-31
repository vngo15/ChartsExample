//
//  StackableChartDataEntry.swift
//  ChartsExample
//
//  Created by Vincent Ngo on 10/27/17.
//  Copyright © 2017 Vincent Ngo. All rights reserved.
//

import UIKit
import Charts

class StackableChartDataEntry: BubbleChartDataEntry {
    var timeSpan: Double? // time in minute
    var colors: [UIColor]? // gradient color
    var highlightedMultipler: CGFloat = 1.2
    var highlightedIcon: NSUIImage?
    var label: String?
    var highlightEnabled = true
    
    init(x: Double, y: Double, size: CGFloat, timeSpan: Double? = nil, icon: NSUIImage? = nil, highlightedIcon: NSUIImage? = nil, data: AnyObject? = nil) {
        super.init(x: x, y: y, size: size, icon: icon, data: data)
        self.timeSpan = timeSpan
        self.highlightedIcon = highlightedIcon
    }
    
    required init() {
        super.init()
    }
}
