//
//  StackableHighlighter.swift
//  ChartsExample
//
//  Created by Vincent Ngo on 10/30/17.
//  Copyright © 2017 Vincent Ngo. All rights reserved.
//

import UIKit
import Charts
class StackableHighlighter: ChartHighlighter {
    open override func getHighlights(xValue: Double, x: CGFloat, y: CGFloat) -> [Highlight] {
        var vals = [Highlight]()
        
        guard let chart = self.chart as? CombinedChartDataProvider
            else { return vals }
        
        if let dataObjects = chart.combinedData?.allData {
            for i in 0..<dataObjects.count {
                let dataObject = dataObjects[i]
                
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
        
        return vals
    }
    
    func buildHighlights(
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

