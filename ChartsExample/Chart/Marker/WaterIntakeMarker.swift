//
//  WaterIntakeMarker.swift
//  ChartsExample
//
//  Created by Vincent Ngo on 11/1/17.
//  Copyright © 2017 Vincent Ngo. All rights reserved.
//

import UIKit
import Charts

class WaterIntakeMarker: MarkerView {
    @IBOutlet weak var cupLabel: UILabel!
    
    override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        guard let entry = entry as? WaterIntakeChartDataEntry else {
            return
        }
        cupLabel.text = entry.count > 1 ? "\(entry.count) CUPS" : "\(entry.count) CUP"
        cupLabel.invalidateIntrinsicContentSize()
        layoutIfNeeded()
    }
}
