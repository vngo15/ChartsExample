//
//  GradientLineChartData.swift
//  ChartsExample
//
//  Created by Vincent Ngo on 10/27/17.
//  Copyright © 2017 Vincent Ngo. All rights reserved.
//

import UIKit
import Charts

class GradientLineChartData: LineChartData {
    weak var chartView: ChartViewBase?
    init(dataSets: [IChartDataSet]?, chartView: ChartViewBase? = nil) {
        super.init(dataSets: dataSets)
        self.chartView = chartView
    }
}
