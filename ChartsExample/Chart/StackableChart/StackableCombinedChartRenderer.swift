//
//  CombinedChartRenderer.swift
//  ChartsExample
//
//  Created by Vincent Ngo on 10/30/17.
//  Copyright © 2017 Vincent Ngo. All rights reserved.
//

import UIKit
import Charts

class StackableCombinedChartRenderer: CombinedChartRenderer {
    override func drawHighlighted(context: CGContext, indices: [Highlight]) {
        if let highlight = indices.first {
            let point = CGPoint(x: highlight.x, y: highlight.y)
            for subRenderer in subRenderers {
                if let gradientRenderer = subRenderer as? GradientLineChartRenderer, let dataSets = gradientRenderer.dataProvider?.lineData?.dataSets {
                    for set in dataSets {
                        gradientRenderer.drawShadedLine(context: context, point: point, set: set as! LineChartDataSet)
                    }
                }
            }
            drawHighlightLines(context: context, point: point)
        }
        super.drawHighlighted(context: context, indices: indices)
    }
    
    public func drawHighlightLines(context: CGContext, point: CGPoint) {
        guard let viewPortHandler = self.viewPortHandler else { return }
        guard let point = chart?.getTransformer(forAxis: .left).pixelForValues(x: Double(point.x), y: Double(point.y)) else {return }
        // draw vertical highlight lines
        let colors = K.Highlighter.colors
        let colorLocations = K.Highlighter.colorLocations
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: colorLocations)!
        let startPoint = CGPoint(x: point.x - K.Highlighter.width, y: viewPortHandler.contentTop)
        let endPoint = CGPoint(x: point.x + K.Highlighter.width, y: viewPortHandler.contentTop)
        context.saveGState()
        context.addRect(CGRect(x: point.x - K.Highlighter.width, y: viewPortHandler.contentBottom, width: K.Highlighter.width * 2, height: viewPortHandler.contentTop - viewPortHandler.contentBottom + K.Highlighter.offset))
        context.clip()
        context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: .drawsBeforeStartLocation)
        context.restoreGState()
    }
    
    public func gradientLineRenderer() -> GradientLineChartRenderer? {
        for r in subRenderers {
            if r.isKind(of: GradientLineChartRenderer.self) {
                return r as? GradientLineChartRenderer
            }
        }
        return nil
    }
}
