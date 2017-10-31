//
//  UIColor+Helper.swift
//  ChartsExample
//
//  Created by Vincent Ngo on 10/23/17.
//  Copyright © 2017 Vincent Ngo. All rights reserved.
//

import UIKit

extension UIColor {
    /**
     * Calculate the gradient color based on the colors and colorPositions array assumming sorted colorPositions array with position is within colorPositions
     */
    static func gradientColor(gradients: [Gradient], position: CGFloat) -> UIColor? {
        if position >= gradients.last?.position ?? 100 {
            return gradients.last?.color
        } else if position <= gradients.first?.position ?? 0 {
            return gradients.first?.color
        }
        
        for i in 0..<gradients.count {
            if i - 1 >= 0 && gradients[i].position > position {
                let ratio = (position - gradients[i - 1].position) / (gradients[i].position - gradients[i - 1].position)
                return mixColor(color1: gradients[i - 1].color, color2: gradients[i].color, mix: ratio)
            }
        }
        
        return nil
    }
    
    static func mixColor(color1: UIColor, color2: UIColor, mix: CGFloat) -> UIColor? {
        guard let component1 = color1.cgColor.components, let component2 = color2.cgColor.components else {
            return nil
        }
        var red: CGFloat = 0.0, blue: CGFloat = 0.0, green: CGFloat = 0.0, alpha: CGFloat = 0.0
        red = component1[0] * (1 - mix) + component2[0] * mix
        green = component1[1] * (1 - mix) + component2[1] * mix
        blue = component1[2] * (1 - mix) + component2[2] * mix
        alpha = component1[3] * (1 - mix) + component2[3] * mix
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }

}

extension Array where Element == UIColor {
    func gradient() -> CGGradient? {
        var gradientColors : [CGFloat] = []
        var cRed : CGFloat = 0
        var cGreen : CGFloat = 0
        var cBlue : CGFloat = 0
        var cAlpha : CGFloat = 0
        for color in self {
            if color.getRed(&cRed, green: &cGreen, blue: &cBlue, alpha: &cAlpha) {
                gradientColors += [cRed, cGreen, cBlue, cAlpha]
            }
        }
        var baseSpace: CGColorSpace? = CGColorSpaceCreateDeviceRGB()
        var gradient : CGGradient?
        gradient = CGGradient(colorSpace: baseSpace!,
                              colorComponents: gradientColors,
                              locations: nil,
                              count: gradientColors.count / 4)
        baseSpace = nil
        return gradient
    }
}
