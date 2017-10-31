//
//  StackableDataSet.swift
//  ChartsExample
//
//  Created by Vincent Ngo on 10/25/17.
//  Copyright © 2017 Vincent Ngo. All rights reserved.
//

import UIKit
import Charts

class StackableChartData: BubbleChartData {
    var contentBottomPosition = -Double.greatestFiniteMagnitude
    var contentTopPosition = Double.greatestFiniteMagnitude
    weak var chartView: ChartViewBase?
    var isDataHighlighted: Bool {
        return chartView != nil ? chartView!.valuesToHighlight() : false
    }
    
    init(dataSets: [IChartDataSet]?, chartView: ChartViewBase? = nil) {
        super.init(dataSets: dataSets)
        self.dataSets = dataSets ?? [IChartDataSet]()
        self.chartView = chartView
    }
    
    override var dataSets: [IChartDataSet] {
        didSet {
            // calculate and normalized all the data
            guard let dataSets = dataSets as? [ChartDataSet] else {
                return
            }
            let count = dataSets.count
            let deltaY: Double = (contentTopPosition - contentBottomPosition) / (Double(count) + 1.0)
            var normalizedPosition = contentBottomPosition + deltaY
            for dataSet in dataSets {
                dataSet.normalizeData(toY: normalizedPosition)
                normalizedPosition += deltaY
            }
            notifyDataChanged()
        }
    }
    
    @available(*, deprecated: 1.0, message: "Set color and highlighted  color with StackableChartDataEntry")
    override func setHighlightCircleWidth(_ width: CGFloat) {
        super.setHighlightCircleWidth(width)
    }
}

fileprivate extension ChartDataSet {
    func normalizeData(toY y: Double) {
        for value in values {
            value.y = y
        }
        notifyDataSetChanged()
    }
}
