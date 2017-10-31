//
//  BaseChartView.swift
//  ChartsExample
//
//  Created by Vincent Ngo on 10/25/17.
//  Copyright © 2017 Vincent Ngo. All rights reserved.
//

import UIKit
import Charts

extension BarLineChartViewBase {
    func styleAxis() {
        xAxisRenderer = InsightXAxisRenderer(viewPortHandler: viewPortHandler, xAxis: xAxis, transformer: getTransformer(forAxis: .left))
        
        // xAxis styling
        let today = Date()
        xAxis.labelTextColor = K.XAxis.axisColor
        xAxis.gridColor = K.XAxis.axisColor
        xAxis.axisLineColor = UIColor.clear
        xAxis.drawGridLinesEnabled = true
        xAxis.drawAxisLineEnabled = true
        xAxis.axisMinimum = today.oneMonthBefore().startOfDate.timeIntervalSinceReferenceDate / 60 // start at midnight of last month
        xAxis.axisMaximum = (today.startOfDate.timeIntervalSinceReferenceDate + K.XAxis.maxAxisOffset) / 60
        xAxis.granularityEnabled = true
        xAxis.valueFormatter = DateAxisFormatter(chart: self)
        xAxis.granularity = K.XAxis.granularity / 60
        xAxis.centerAxisLabelsEnabled = true
        
        // yAxis styling
        leftAxis.axisMaximum = 110;
        leftAxis.axisMinimum = -10;
        leftAxis.drawGridLinesEnabled = false
        leftAxis.drawZeroLineEnabled = false
        leftAxis.granularityEnabled = false
        leftAxis.enabled = true
        leftAxis.gridColor = UIColor.clear
        leftAxis.axisLineColor = UIColor.clear
        leftAxis.labelTextColor = UIColor.clear
        leftAxis.xOffset = -10 // Set xAxis offset here
        rightAxis.enabled = false
        chartDescription?.textColor = UIColor.clear
        
        // Misc
        setScaleMinima(4.5, scaleY: 1)
        dragEnabled = true
        scaleYEnabled = false
        scaleXEnabled = false
        drawGridBackgroundEnabled = false
        legend.enabled = false
    }
}
