//
//  CombinedChartViewViewController.swift
//  ChartsExample
//
//  Created by Vincent Ngo on 10/25/17.
//  Copyright © 2017 Vincent Ngo. All rights reserved.
//
//  Basically all the combination of StackableChart (SC) and GradientLineChart (GLC)
//  ------------- y = 500 or whatever, defined in StakableChartData.contentTopPosition
//  |           | and leftAxis.axisMaximum
//  |    SC     |
//  |           |
//  ------------- y = 110, defined in StackableChartData.contentBottomPosition
//  |           |
//  |    GLC    |
//  |           |
//  ------------- y = - 10
//

import UIKit
import Charts

class StackableChartView: CombinedChartView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        style()
    }
    
    private func style() {
        styleAxis()
        leftAxis.axisMaximum = 500
        
        data = CombinedChartData(dataSet: nil)
        if !(combinedData?.bubbleData is StackableChartData) {
            combinedData?.bubbleData = StackableChartData(dataSets: nil, chartView:self)
        }
        highlighter = StackableHighlighter(chart: self)
        renderer = StackableCombinedChartRenderer(chart: self, animator: chartAnimator, viewPortHandler: viewPortHandler)
        if let combinedRenderer = renderer as? CombinedChartRenderer {
            combinedRenderer.subRenderers.append(StackableChartRenderer(dataProvider: self, animator: chartAnimator, viewPortHandler: viewPortHandler))
            combinedRenderer.subRenderers.append(GradientLineChartRenderer(dataProvider: self, animator: chartAnimator, viewPortHandler: viewPortHandler))
        }
    }
    
    // Add stackable data
    func setStackableDataSets(xAxisSet: [[Double]]) {
        //TODO update this
        var dataSets = [ChartDataSet]()
        for xAxisValues in xAxisSet {
            var xEntries = [StackableChartDataEntry]()
            for xValue in xAxisValues {
                let entry = StackableChartDataEntry(x: xValue, y: 50, size: 20)
                entry.highlightedIcon = UIImage(named: "icon")
                entry.icon = UIImage(named: "icon")
                entry.highlightedMultipler = 1.5
//                entry.timeSpan = 450 // in minute
                entry.label = "test"
                entry.highlightEnabled = arc4random_uniform(100) % 2 == 0 // indicate whether the chart should highlight 
                xEntries.append(entry)
            }
            // todo add label
            let set = BubbleChartDataSet(values: xEntries, label: "Bubble")
            set.setColor(UIColor.white)
            set.drawValuesEnabled = false
            set.drawIconsEnabled = false
            dataSets.append(set)
        }
        
        if let data = combinedData?.bubbleData as? StackableChartData {
            data.contentTopPosition = leftAxis.axisMaximum
            data.contentBottomPosition = leftAxis.axisMinimum + 110
            data.setValueTextColor(UIColor.white)
            data.dataSets = dataSets
        }
        notifyDataSetChanged()
    }
    
    // x axis is in minute from timeIntervalSinceReferenceDate
    func setLineChartData(entries: [ChartDataEntry]) {
        //TODO
        if let dataCount = lineData?.dataSets.count, dataCount > 0 {
            let set1 = data!.dataSets[0] as! GradientLineChartDataSet
            set1.values = entries
            moveViewToX(set1.xMax)
            data?.notifyDataChanged()
            notifyDataSetChanged()
        } else {
            let set1 = GradientLineChartDataSet(values: entries, label: "CONDITION")
            set1.highlightEnabled = false
            set1.drawIconsEnabled = false
            set1.drawValuesEnabled = false
            set1.drawCirclesEnabled = false
            set1.lineWidth = 2.0
            set1.circleRadius = 3.0
            set1.gradients = K.Colors.gradients
            set1.mode = .horizontalBezier
            set1.valueColors = [UIColor.white]
            moveViewToX(set1.xMax)
            combinedData?.lineData = GradientLineChartData(dataSets: [set1], chartView: self)
        }
    }
    
    override func highlightValue(_ highlight: Highlight?, callDelegate: Bool) {
        super.highlightValue(highlight, callDelegate: callDelegate)
        
        if let highlight = highlight, let highlights = (highlighter as? StackableHighlighter)?.getHighlights(xValue: highlight.x, x: 0, y: 0) {
            highlightValues(highlights) // highlight multiple values
        }
    }
   
}

