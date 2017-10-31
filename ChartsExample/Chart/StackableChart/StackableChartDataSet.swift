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
    var scheduledDataSet: BubbleChartDataSet? {
        didSet {
            scheduledDataSet?.highlightEnabled = false
        }
    }
}
