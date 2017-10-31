//
//  Constant.swift
//  ChartsExample
//
//  Created by Vincent Ngo on 10/23/17.
//  Copyright © 2017 Vincent Ngo. All rights reserved.
//

import UIKit

struct K {
    struct Highlighter {
        static let width:CGFloat = 8
        static let colors = [edgeColor, midColor, centerColor, midColor, edgeColor]
        static let colorLocations: [CGFloat] = [0.0, 0.4, 0.5, 0.6, 1]
        static let offset = XAxis.gridLineHeight + 4.0
        private static let edgeColor = UIColor(white: 1, alpha: 0.0).cgColor
        private static let midColor = UIColor(white: 1, alpha: 0.4).cgColor
        private static let centerColor = UIColor.white.cgColor
    }
    
    struct Colors {
        static let gradients: [Gradient] = [ (UIColor.red, 10), (UIColor.yellow, 30), (UIColor.green, 60)]
        static let shader = UIColor.black.withAlphaComponent(0.3).cgColor
    }
    
    struct XAxis {
        static let maxAxisOffset = 86400.0 // in seconds
        static let granularity = 86400.0 // 1 day in seconds
        static let axisColor = UIColor.white
        static let gridLineHeight: CGFloat = 4.0
    }
    
    struct Legend {
        static let color = UIColor.white
        static let font = UIFont.systemFont(ofSize: 10.0)
    }
}
