//
//  GradientLineChartDataSet.swift
//  ChartsExample
//
//  Created by Vincent Ngo on 10/23/17.
//  Copyright © 2017 Vincent Ngo. All rights reserved.
//

import UIKit
import Charts

public class GradientLineChartDataSet: LineChartDataSet {
    var gradients: [Gradient]?
    var gradientEnabled: Bool = true
    var circularHighlightMultiplier: CGFloat = 1.7
    var circularHighlightIndicatorEnabled = true
    
    // return scale factor for high and low point of the graph
    func circleScaleFactor(atIndex index: Int) -> CGFloat {
        if values.max() == values[index] || values.min() == values[index] {
            return circularHighlightMultiplier
        }
        return 1
    }
    
    func getHoleCircleColor(atIndex index: Int) -> NSUIColor? {
        if values.max() == values[index] || values.min() == values[index] {
            return UIColor.gradientColor(gradients: K.Colors.gradients, position: CGFloat(values[index].y))
        }
        return getCircleColor(atIndex: index)
    }
}
