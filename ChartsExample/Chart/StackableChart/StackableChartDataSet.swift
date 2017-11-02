//
//  StackableChartDataSet.swift
//  ChartsExample
//
//  Created by Vincent Ngo on 10/31/17.
//  Copyright © 2017 Vincent Ngo. All rights reserved.
//

import UIKit
import Charts

class StackableChartDataSet: BubbleChartDataSet {
    var scheduleTimeEnabled: Bool = false
    var legendEnabled: Bool = false // enable/disable legend above data set
    var scheduledDataSet: BubbleChartDataSet? {
        didSet {
            scheduledDataSet?.highlightEnabled = false
        }
    }
    
    @available(*, deprecated: 1.0, message: "Use StackableChartDataEntry.colors instead")
    override func setColor(_ color: NSUIColor) {}
    
    @available(*, deprecated: 1.0, message: "Use StackableChartDataEntry.colors instead")
    override func setColor(_ color: NSUIColor, alpha: CGFloat) {}
    
    @available(*, deprecated: 1.0, message: "Use StackableChartDataEntry.colors instead")
    override func setColors(_ colors: NSUIColor...) {}
    
    @available(*, deprecated: 1.0, message: "Use StackableChartDataEntry.colors instead")
    override func setColors(_ colors: [NSUIColor], alpha: CGFloat) {}
}
