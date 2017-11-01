//
//  ActivityChartMarker.swift
//  ChartsExample
//
//  Created by Vincent Ngo on 10/31/17.
//  Copyright © 2017 Vincent Ngo. All rights reserved.
//

import UIKit
import Charts
class ActivityChartMarker: MarkerView {
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        titleLabel.invalidateIntrinsicContentSize()
        durationLabel.invalidateIntrinsicContentSize()
        layoutIfNeeded()
    }
}
