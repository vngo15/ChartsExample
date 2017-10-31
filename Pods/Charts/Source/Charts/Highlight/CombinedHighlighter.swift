//
//  CombinedHighlighter.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics

@objc(CombinedChartHighlighter)
open class CombinedHighlighter: ChartHighlighter {
    /// bar highlighter for supporting stacked highlighting
    fileprivate var barHighlighter: BarHighlighter?
    
    @objc public init(chart: CombinedChartDataProvider, barDataProvider: BarChartDataProvider) {
        super.init(chart: chart)
        
        // if there is BarData, create a BarHighlighter
        self.barHighlighter = barDataProvider.barData == nil ? nil : BarHighlighter(chart: barDataProvider)
    }
    
    open override func getHighlights(xValue: Double, x: CGFloat, y: CGFloat) -> [Highlight] {
        var vals = [Highlight]()
        
        guard let chart = self.chart as? CombinedChartDataProvider
            else { return vals }
        
        if let dataObjects = chart.combinedData?.allData {
            for i in 0..<dataObjects.count {
                let dataObject = dataObjects[i]
                
                // in case of BarData, let the BarHighlighter take over
                if barHighlighter != nil && dataObject is BarChartData {
                    if let high = barHighlighter?.getHighlight(x: x, y: y) {
                        high.dataIndex = i
                        vals.append(high)
                    }
                } else {
                    for j in 0..<dataObject.dataSetCount {
                        guard let dataSet = dataObjects[i].getDataSetByIndex(j)
                            else { continue }
                        
                        // don't include datasets that cannot be highlighted
                        if !dataSet.isHighlightEnabled {
                            continue
                        }
                        
                        let highs = buildHighlights(dataSet: dataSet, dataSetIndex: j, xValue: xValue, rounding: .closest)
                        
                        for high in highs {
                            high.dataIndex = i
                            vals.append(high)
                        }
                    }
                }
            }
        }
        
        return vals
    }
    
    override func buildHighlights(
        dataSet set: IChartDataSet,
        dataSetIndex: Int,
        xValue: Double,
        rounding: ChartDataSetRounding) -> [Highlight] {
        var highlights = [Highlight]()
        
        guard let chart = self.chart as? BarLineScatterCandleBubbleChartDataProvider
            else { return highlights }
        
        var entries = set.entriesForXValue(xValue)
        if entries.count == 0 {
            // Try to find closest x-value and take all entries for that x-value
            if let closest = set.entryForXValue(xValue, closestToY: Double.nan, rounding: rounding) {
                entries = set.entriesForXValue(closest.x)
            }
        }
        
        for e in entries {
            let px = chart.getTransformer(forAxis: set.axisDependency).pixelForValues(x: e.x, y: e.y)
            
            highlights.append(Highlight(x: e.x, y: e.y, xPx: px.x, yPx: px.y, dataSetIndex: dataSetIndex, axis: set.axisDependency))
        }
        
        return highlights
    }

}
