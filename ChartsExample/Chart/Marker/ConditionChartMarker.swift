//
//  ConditionChartMarker.swift
//  ChartsExample
//
//  Created by Vincent Ngo on 10/23/17.
//  Copyright © 2017 Vincent Ngo. All rights reserved.
//

import UIKit
import Charts

class ConditionChartMarker: MarkerView {
    @IBOutlet weak var label: UILabel!
    
    var gradients: [Gradient]?
    
    override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        label.text = String(format: "%1.0f%% Excellent", entry.y)
        if let gradients = gradients, let color = UIColor.gradientColor(gradients: gradients, position: CGFloat(entry.y)) {
            label.textColor = color
        } else {
            label.textColor = UIColor.white
        }
        layoutIfNeeded()
    }
}
