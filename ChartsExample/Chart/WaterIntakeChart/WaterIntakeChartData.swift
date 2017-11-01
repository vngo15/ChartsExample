//
//  WaterIntakeChartData.swift
//  ChartsExample
//
//  Created by Vincent Ngo on 10/31/17.
//  Copyright © 2017 Vincent Ngo. All rights reserved.
//

import UIKit
import Charts

class WaterIntakeChartData: BubbleChartData {
    var contentBottomPosition = -Double.greatestFiniteMagnitude
    var contentTopPosition = Double.greatestFiniteMagnitude
    var normalizedY: Double {
        return (contentTopPosition - contentBottomPosition) + contentBottomPosition
    }
    var normalizedYMax: Double {
        if let values = (dataSets.first as? ChartDataSet)?.values as? [WaterIntakeChartDataEntry], let maxEntry = values.max() {
            return normalizedY + maxEntry.normalizedHeight * Double(maxEntry.highlightedMultipler)
        }
        return 0
    }
    var normalizedYMin: Double {
        if let values = (dataSets.first as? ChartDataSet)?.values as? [WaterIntakeChartDataEntry], let maxEntry = values.max() {
            return normalizedY - maxEntry.normalizedHeight * Double(maxEntry.highlightedMultipler)
        }
        return 0
    }
    weak var chartView: ChartViewBase?
    var isDataHighlighted: Bool {
        return chartView != nil ? chartView!.valuesToHighlight() : false
    }
    
    init(dataSets: [WaterIntakeChartDataSet]?, chartView: ChartViewBase? = nil) {
        super.init(dataSets: dataSets)
        self.dataSets = dataSets ?? [IChartDataSet]()
        self.chartView = chartView
    }
    
    override var dataSets: [IChartDataSet] {
        didSet {
            guard dataSets is [WaterIntakeChartDataSet], dataSets.count == 1, let dataSet = dataSets.first as? WaterIntakeChartDataSet else {
                return
            }
            dataSet.normalizeData(top: contentTopPosition, bottom: contentBottomPosition)
            notifyDataChanged()
        }
    }
    
    @available(*, deprecated: 1.0, message: "Set color and highlighted  color with StackableChartDataEntry")
    override func setHighlightCircleWidth(_ width: CGFloat) {
        super.setHighlightCircleWidth(width)
    }
}

fileprivate extension ChartDataSet {
    func normalizeData(top: Double, bottom: Double) {
        guard let values = values as? [WaterIntakeChartDataEntry], !values.isEmpty else {return}
        let y = (top - bottom) / 2  + bottom
        for value in values {
            value.y = y
            value.normalizedHeight = Double(value.count) * (top - y) / Double(values.max()?.count ?? 1)
        }
        notifyDataSetChanged()
    }
}

fileprivate extension Array where Element == WaterIntakeChartDataEntry {
    fileprivate func max() -> WaterIntakeChartDataEntry? {
        guard var max = first else {return nil}
        for e in self {
            if e.count > max.count {
                max = e
            }
        }
        return max
    }
}
