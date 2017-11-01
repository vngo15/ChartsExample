//
//  WaterIntakeTotalMarker.swift
//  ChartsExample
//
//  Created by Vincent Ngo on 11/1/17.
//  Copyright © 2017 Vincent Ngo. All rights reserved.
//

import UIKit
import Charts
class WaterIntakeTotalMarker: MarkerView {
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var totalSublabel: UILabel!
    override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        guard let entry = entry as? WaterIntakeChartDataEntry else { return }
        totalLabel.text = "\(entry.count)"
        totalSublabel.text = "\(entry.count)/02 TOTAL"
    }
}
