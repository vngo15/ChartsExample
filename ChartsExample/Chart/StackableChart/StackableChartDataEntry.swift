//
//  StackableChartDataEntry.swift
//  ChartsExample
//
//  Created by Vincent Ngo on 10/27/17.
//  Copyright © 2017 Vincent Ngo. All rights reserved.
//

import UIKit
import Charts

class StackableChartDataEntry: BubbleChartDataEntry {
    var timeSpan: Double? // time in minute
    var colors: [UIColor] = [UIColor.white] // gradient color from left to right
    var highlightedMultipler: CGFloat = 1.2
    var highlightedIcon: NSUIImage?
    var label: String?
    var strokeColor: UIColor?
    var halo: Bool = false
    var haloColor: UIColor?
    var haloSpacing: CGFloat = 2.0
    var haloWidth: CGFloat = 2.0
    
    init(x: Double, y: Double, size: CGFloat, timeSpan: Double? = nil, icon: NSUIImage? = nil, highlightedIcon: NSUIImage? = nil, data: AnyObject? = nil) {
        super.init(x: x, y: y, size: size, icon: icon, data: data)
        self.timeSpan = timeSpan
        self.highlightedIcon = highlightedIcon
    }
    
    required init() {
        super.init()
    }

    func getHaloRect() -> CGRect {

        let haloOffset = haloSpacing + haloWidth

        return CGRect(x: CGFloat(x) - haloOffset,
                      y: CGFloat(y) - haloOffset,
                      width: size + haloOffset * 2,
                      height: size + haloOffset * 2)
    }

}
