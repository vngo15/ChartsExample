//
//  WaterIntakeChartDataEntry.swift
//  ChartsExample
//
//  Created by Vincent Ngo on 10/31/17.
//  Copyright © 2017 Vincent Ngo. All rights reserved.
//

import UIKit
import Charts

class WaterIntakeChartDataEntry: BubbleChartDataEntry {
    var count: Double = 0
    var colors: [UIColor] = [UIColor.white] // gradient color from top to bottom
    var highlightedMultipler: CGFloat = 1.2
    var normalizedHeight: Double = 0
    
    init(x: Double, y: Double, size: CGFloat, count: Double) {
        super.init(x: x, y: y, size: size)
        self.normalizedHeight = Double(size)
        self.count = count
    }
    
    required init() {
        super.init()
    }
}
