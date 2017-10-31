//
//  GradientLineDataSet.swift
//  ChartsExample
//
//  Created by Vincent Ngo on 10/19/17.
//  Copyright © 2017 Vincent Ngo. All rights reserved.
//

import UIKit
import Charts

typealias Gradient = (color: UIColor, position: CGFloat)

public class GradientLineChartRenderer: LineRadarRenderer {
    fileprivate let _xBounds = XBounds()
    private var pathCopy: CGPath?
    
    @objc open weak var dataProvider: LineChartDataProvider?
    weak var highlighter: ChartHighlighter?
    
    @objc public init(dataProvider: LineChartDataProvider?, animator: Animator?, viewPortHandler: ViewPortHandler?, hightLighter: ChartHighlighter? = nil) {
        super.init(animator: animator, viewPortHandler: viewPortHandler)
        self.highlighter = hightLighter
        self.dataProvider = dataProvider
    }
    
    open override func drawData(context: CGContext) {
        guard let lineData = dataProvider?.lineData else { return }
        
        for i in 0 ..< lineData.dataSetCount {
            guard let set = lineData.getDataSetByIndex(i) else { continue }
            
            if set.isVisible {
                if !(set is ILineChartDataSet) {
                    fatalError("Datasets for LineChartRenderer must conform to ILineChartDataSet")
                }
                
                drawDataSet(context: context, dataSet: set as! ILineChartDataSet)
            }
            if set.isHighlightEnabled {
                drawShader(context: context)
            }
            drawCircles(context: context)
        }
    }
    
    @objc open func drawDataSet(context: CGContext, dataSet: ILineChartDataSet) {
        if dataSet.entryCount < 1 {
            return
        }
        
        context.saveGState()
        
        context.setLineWidth(dataSet.lineWidth)
        if dataSet.lineDashLengths != nil {
            context.setLineDash(phase: dataSet.lineDashPhase, lengths: dataSet.lineDashLengths!)
        } else {
            context.setLineDash(phase: 0.0, lengths: [])
        }
        
        // if drawing cubic lines is enabled
        switch dataSet.mode {
        case .linear: fallthrough
        case .stepped:
            drawLinear(context: context, dataSet: dataSet)
            
        case .cubicBezier:
            drawCubicBezier(context: context, dataSet: dataSet)
            
        case .horizontalBezier:
            drawHorizontalBezier(context: context, dataSet: dataSet)
        }
        
        context.restoreGState()
        // draw label
        if let dataProvider = dataProvider, let viewPortHandler = viewPortHandler {
            let labelOffset = (dataProvider.chartYMax - dataProvider.chartYMin) / Double(dataProvider.data?.dataSetCount ?? 1) / 4
            let pointBuffer = dataProvider.getTransformer(forAxis: dataSet.axisDependency).pixelForValues(x: 0.0, y: dataSet.yMax + labelOffset)
            drawLabel(context: context, x: viewPortHandler.contentLeft + 10.0, y: pointBuffer.y, label: dataSet.label ?? "", font: K.Legend.font, textColor: K.Legend.color)
        }
    }
    
    @objc open func drawCubicBezier(context: CGContext, dataSet: ILineChartDataSet) {
        guard
            let dataProvider = dataProvider,
            let animator = animator
            else { return }
        
        let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
        
        let phaseY = animator.phaseY
        
        _xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)
        
        let intensity = dataSet.cubicIntensity
        
        // the path for the cubic-spline
        let cubicPath = CGMutablePath()
        
        let valueToPixelMatrix = trans.valueToPixelMatrix
        
        if _xBounds.range >= 1 {
            var prevDx: CGFloat = 0.0
            var prevDy: CGFloat = 0.0
            var curDx: CGFloat = 0.0
            var curDy: CGFloat = 0.0
            
            // Take an extra point from the left, and an extra from the right.
            // That's because we need 4 points for a cubic bezier (cubic=4), otherwise we get lines moving and doing weird stuff on the edges of the chart.
            // So in the starting `prev` and `cur`, go -2, -1
            // And in the `lastIndex`, add +1
            
            let firstIndex = _xBounds.min + 1
            let lastIndex = _xBounds.min + _xBounds.range
            
            var prevPrev: ChartDataEntry! = nil
            var prev: ChartDataEntry! = dataSet.entryForIndex(max(firstIndex - 2, 0))
            var cur: ChartDataEntry! = dataSet.entryForIndex(max(firstIndex - 1, 0))
            var next: ChartDataEntry! = cur
            var nextIndex: Int = -1
            
            if cur == nil { return }
            
            // let the spline start
            cubicPath.move(to: CGPoint(x: CGFloat(cur.x), y: CGFloat(cur.y * phaseY)), transform: valueToPixelMatrix)
            
            for j in stride(from: firstIndex, through: lastIndex, by: 1) {
                prevPrev = prev
                prev = cur
                cur = nextIndex == j ? next : dataSet.entryForIndex(j)
                
                nextIndex = j + 1 < dataSet.entryCount ? j + 1 : j
                next = dataSet.entryForIndex(nextIndex)
                
                if next == nil { break }
                
                prevDx = CGFloat(cur.x - prevPrev.x) * intensity
                prevDy = CGFloat(cur.y - prevPrev.y) * intensity
                curDx = CGFloat(next.x - prev.x) * intensity
                curDy = CGFloat(next.y - prev.y) * intensity
                
                cubicPath.addCurve(
                    to: CGPoint(
                        x: CGFloat(cur.x),
                        y: CGFloat(cur.y) * CGFloat(phaseY)),
                    control1: CGPoint(
                        x: CGFloat(prev.x) + prevDx,
                        y: (CGFloat(prev.y) + prevDy) * CGFloat(phaseY)),
                    control2: CGPoint(
                        x: CGFloat(cur.x) - curDx,
                        y: (CGFloat(cur.y) - curDy) * CGFloat(phaseY)),
                    transform: valueToPixelMatrix)
            }
        }
        
        context.saveGState()
        pathCopy = cubicPath.mutableCopy()
        
        if dataSet.isDrawFilledEnabled {
            // Copy this path because we make changes to it
            let fillPath = cubicPath.mutableCopy()
            
            drawCubicFill(context: context, dataSet: dataSet, spline: fillPath!, matrix: valueToPixelMatrix, bounds: _xBounds)
        }
        
        if let gDataSet = dataSet as? GradientLineChartDataSet, gDataSet.gradientEnabled {
            drawGradientLine(context: context, dataSet: dataSet, spline: cubicPath, matrix: valueToPixelMatrix)
        } else {
            context.beginPath()
            context.addPath(cubicPath)
            context.setStrokeColor(dataSet.colors.first!.cgColor)
            context.strokePath()
        }
        
        context.restoreGState()
    }
    
    @objc open func drawHorizontalBezier(context: CGContext, dataSet: ILineChartDataSet) {
        guard
            let dataProvider = dataProvider,
            let animator = animator
            else { return }
        
        let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
        
        let phaseY = animator.phaseY
        
        _xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)
        
        // get the color that is specified for this position from the DataSet
        let drawingColor = dataSet.colors.first!
        
        // the path for the cubic-spline
        let cubicPath = CGMutablePath()
        
        let valueToPixelMatrix = trans.valueToPixelMatrix
        
        if _xBounds.range >= 1 {
            var prev: ChartDataEntry! = dataSet.entryForIndex(_xBounds.min)
            var cur: ChartDataEntry! = prev
            
            if cur == nil { return }
            
            // let the spline start
            cubicPath.move(to: CGPoint(x: CGFloat(cur.x), y: CGFloat(cur.y * phaseY)), transform: valueToPixelMatrix)
            
            for j in stride(from: (_xBounds.min + 1), through: _xBounds.range + _xBounds.min, by: 1)
            {
                prev = cur
                cur = dataSet.entryForIndex(j)
                
                let cpx = CGFloat(prev.x + (cur.x - prev.x) / 2.0)
                
                cubicPath.addCurve(
                    to: CGPoint(
                        x: CGFloat(cur.x),
                        y: CGFloat(cur.y * phaseY)),
                    control1: CGPoint(
                        x: cpx,
                        y: CGFloat(prev.y * phaseY)),
                    control2: CGPoint(
                        x: cpx,
                        y: CGFloat(cur.y * phaseY)),
                    transform: valueToPixelMatrix)
            }
        }
        pathCopy = cubicPath.copy()
        context.saveGState()
        
        if dataSet.isDrawFilledEnabled {
            // Copy this path because we make changes to it
            let fillPath = cubicPath.mutableCopy()
            
            drawCubicFill(context: context, dataSet: dataSet, spline: fillPath!, matrix: valueToPixelMatrix, bounds: _xBounds)
        }
        
        context.beginPath()
        context.addPath(cubicPath)
        context.setStrokeColor(drawingColor.cgColor)
        context.strokePath()
        
        context.restoreGState()
        
        drawGradientLine(context: context, dataSet: dataSet, spline: cubicPath, matrix: valueToPixelMatrix)
    }
    
    open func drawCubicFill(
        context: CGContext,
        dataSet: ILineChartDataSet,
        spline: CGMutablePath,
        matrix: CGAffineTransform,
        bounds: XBounds) {
        guard
            let dataProvider = dataProvider
            else { return }
        
        if bounds.range <= 0 {
            return
        }
        
        let fillMin = dataSet.fillFormatter?.getFillLinePosition(dataSet: dataSet, dataProvider: dataProvider) ?? 0.0
        
        var pt1 = CGPoint(x: CGFloat(dataSet.entryForIndex(bounds.min + bounds.range)?.x ?? 0.0), y: fillMin)
        var pt2 = CGPoint(x: CGFloat(dataSet.entryForIndex(bounds.min)?.x ?? 0.0), y: fillMin)
        pt1 = pt1.applying(matrix)
        pt2 = pt2.applying(matrix)
        
        spline.addLine(to: pt1)
        spline.addLine(to: pt2)
        spline.closeSubpath()
        
        if dataSet.fill != nil {
            drawFilledPath(context: context, path: spline, fill: dataSet.fill!, fillAlpha: dataSet.fillAlpha)
        } else {
            drawFilledPath(context: context, path: spline, fillColor: dataSet.fillColor, fillAlpha: dataSet.fillAlpha)
        }
    }
    
    fileprivate var _lineSegments = [CGPoint](repeating: CGPoint(), count: 2)
    
    @objc open func drawLinear(context: CGContext, dataSet: ILineChartDataSet) {
        guard
            let dataProvider = dataProvider,
            let animator = animator,
            let viewPortHandler = self.viewPortHandler
            else { return }
        
        let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
        
        let valueToPixelMatrix = trans.valueToPixelMatrix
        
        let entryCount = dataSet.entryCount
        let isDrawSteppedEnabled = dataSet.mode == .stepped
        let pointsPerEntryPair = isDrawSteppedEnabled ? 4 : 2
        
        let phaseY = animator.phaseY
        
        _xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)
        
        // if drawing filled is enabled
        if dataSet.isDrawFilledEnabled && entryCount > 0 {
            drawLinearFill(context: context, dataSet: dataSet, trans: trans, bounds: _xBounds)
        }
        
        context.saveGState()
        
        context.setLineCap(dataSet.lineCapType)
        
        // more than 1 color
        if dataSet.colors.count > 1 {
            if _lineSegments.count != pointsPerEntryPair {
                // Allocate once in correct size
                _lineSegments = [CGPoint](repeating: CGPoint(), count: pointsPerEntryPair)
            }
            
            for j in stride(from: _xBounds.min, through: _xBounds.range + _xBounds.min, by: 1) {
                var e: ChartDataEntry! = dataSet.entryForIndex(j)
                
                if e == nil { continue }
                
                _lineSegments[0].x = CGFloat(e.x)
                _lineSegments[0].y = CGFloat(e.y * phaseY)
                
                if j < _xBounds.max {
                    e = dataSet.entryForIndex(j + 1)
                    
                    if e == nil { break }
                    
                    if isDrawSteppedEnabled {
                        _lineSegments[1] = CGPoint(x: CGFloat(e.x), y: _lineSegments[0].y)
                        _lineSegments[2] = _lineSegments[1]
                        _lineSegments[3] = CGPoint(x: CGFloat(e.x), y: CGFloat(e.y * phaseY))
                    } else {
                        _lineSegments[1] = CGPoint(x: CGFloat(e.x), y: CGFloat(e.y * phaseY))
                    }
                } else {
                    _lineSegments[1] = _lineSegments[0]
                }
                
                for i in 0..<_lineSegments.count {
                    _lineSegments[i] = _lineSegments[i].applying(valueToPixelMatrix)
                }
                
                if (!viewPortHandler.isInBoundsRight(_lineSegments[0].x)) {
                    break
                }
                
                // make sure the lines don't do shitty things outside bounds
                if !viewPortHandler.isInBoundsLeft(_lineSegments[1].x)
                    || (!viewPortHandler.isInBoundsTop(_lineSegments[0].y) && !viewPortHandler.isInBoundsBottom(_lineSegments[1].y)) {
                    continue
                }
                
                // get the color that is set for this line-segment
                context.setStrokeColor(dataSet.color(atIndex: j).cgColor)
                context.strokeLineSegments(between: _lineSegments)
            }
        } else { // only one color per dataset
            
            var e1: ChartDataEntry!
            var e2: ChartDataEntry!
            
            e1 = dataSet.entryForIndex(_xBounds.min)
            
            if e1 != nil {
                context.beginPath()
                var firstPoint = true
                
                for x in stride(from: _xBounds.min, through: _xBounds.range + _xBounds.min, by: 1) {
                    e1 = dataSet.entryForIndex(x == 0 ? 0 : (x - 1))
                    e2 = dataSet.entryForIndex(x)
                    
                    if e1 == nil || e2 == nil { continue }
                    
                    let pt = CGPoint(
                        x: CGFloat(e1.x),
                        y: CGFloat(e1.y * phaseY)
                        ).applying(valueToPixelMatrix)
                    
                    if firstPoint {
                        context.move(to: pt)
                        firstPoint = false
                    } else {
                        context.addLine(to: pt)
                    }
                    
                    if isDrawSteppedEnabled {
                        context.addLine(to: CGPoint(
                            x: CGFloat(e2.x),
                            y: CGFloat(e1.y * phaseY)
                            ).applying(valueToPixelMatrix))
                    }
                    
                    context.addLine(to: CGPoint(
                        x: CGFloat(e2.x),
                        y: CGFloat(e2.y * phaseY)
                        ).applying(valueToPixelMatrix))
                }
                
                if !firstPoint {
                    context.setStrokeColor(dataSet.color(atIndex: 0).cgColor)
                    context.strokePath()
                }
            }
            
        }
        context.restoreGState()
        if let gDataSet = dataSet as? GradientLineChartDataSet, gDataSet.gradientEnabled {
            let path = generatePath(
                dataSet: dataSet,
                fillMin: dataSet.fillFormatter?.getFillLinePosition(dataSet: dataSet, dataProvider: dataProvider) ?? 0.0,
                from: _xBounds.min,
                to: _xBounds.range + _xBounds.min,
                matrix: trans.valueToPixelMatrix)
            pathCopy = path
            
            drawGradientLine(context: context, dataSet: dataSet, spline: path, matrix: valueToPixelMatrix)
        }
    }
    
    open func drawLinearFill(context: CGContext, dataSet: ILineChartDataSet, trans: Transformer, bounds: XBounds) {
        guard let dataProvider = dataProvider else { return }
        
        let filled = generateFilledPath(
            dataSet: dataSet,
            fillMin: dataSet.fillFormatter?.getFillLinePosition(dataSet: dataSet, dataProvider: dataProvider) ?? 0.0,
            bounds: bounds,
            matrix: trans.valueToPixelMatrix)
        
        if dataSet.fill != nil {
            drawFilledPath(context: context, path: filled, fill: dataSet.fill!, fillAlpha: dataSet.fillAlpha)
        } else {
            drawFilledPath(context: context, path: filled, fillColor: dataSet.fillColor, fillAlpha: dataSet.fillAlpha)
        }
    }
    
    /// Generates the path that is used for filled drawing.
    fileprivate func generateFilledPath(dataSet: ILineChartDataSet, fillMin: CGFloat, bounds: XBounds, matrix: CGAffineTransform) -> CGPath {
        let phaseY = animator?.phaseY ?? 1.0
        let isDrawSteppedEnabled = dataSet.mode == .stepped
        let matrix = matrix
        
        var e: ChartDataEntry!
        
        let filled = CGMutablePath()
        
        e = dataSet.entryForIndex(bounds.min)
        if e != nil {
            filled.move(to: CGPoint(x: CGFloat(e.x), y: fillMin), transform: matrix)
            filled.addLine(to: CGPoint(x: CGFloat(e.x), y: CGFloat(e.y * phaseY)), transform: matrix)
        }
        
        // create a new path
        for x in stride(from: (bounds.min + 1), through: bounds.range + bounds.min, by: 1) {
            guard let e = dataSet.entryForIndex(x) else { continue }
            
            if isDrawSteppedEnabled {
                guard let ePrev = dataSet.entryForIndex(x-1) else { continue }
                filled.addLine(to: CGPoint(x: CGFloat(e.x), y: CGFloat(ePrev.y * phaseY)), transform: matrix)
            }
            
            filled.addLine(to: CGPoint(x: CGFloat(e.x), y: CGFloat(e.y * phaseY)), transform: matrix)
        }
        
        // close up
        e = dataSet.entryForIndex(bounds.range + bounds.min)
        if e != nil {
            filled.addLine(to: CGPoint(x: CGFloat(e.x), y: fillMin), transform: matrix)
        }
        filled.closeSubpath()
        
        return filled
    }
    
    /// Generates the path that is used for gradient drawing.
    private func generatePath(dataSet: ILineChartDataSet, fillMin: CGFloat, from: Int, to: Int, matrix: CGAffineTransform) -> CGPath {
        let phaseX = CGFloat(animator?.phaseX ?? 0)
        let phaseY = CGFloat(animator?.phaseY ?? 0)
        
        var e: ChartDataEntry!
        
        let generatedPath = CGMutablePath()
        e = dataSet.entryForIndex(from)
        if e != nil {
            generatedPath.move(to: CGPoint(x: CGFloat(e.x), y: CGFloat(e.y) * phaseY), transform: matrix)
        }
        // create a new path
        for _ in from + 1...Int(ceil(CGFloat(to - from) * phaseX + CGFloat(from)))  {
            guard let e = dataSet.entryForIndex(from) else { continue }
            generatedPath.move(to: CGPoint(x: CGFloat(e.x), y: CGFloat(e.y) * phaseY), transform: matrix)
        }
        return generatedPath
    }
    
    open override func drawValues(context: CGContext) {
        guard
            let dataProvider = dataProvider,
            let lineData = dataProvider.lineData,
            let animator = animator,
            let viewPortHandler = self.viewPortHandler
            else { return }
        
        if isDrawingValuesAllowed(dataProvider: dataProvider) {
            var dataSets = lineData.dataSets
            
            let phaseY = animator.phaseY
            
            var pt = CGPoint()
            
            for i in 0 ..< dataSets.count {
                guard let dataSet = dataSets[i] as? ILineChartDataSet else { continue }
                
                if !shouldDrawValues(forDataSet: dataSet) {
                    continue
                }
                
                let valueFont = dataSet.valueFont
                
                guard let formatter = dataSet.valueFormatter else { continue }
                
                let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
                let valueToPixelMatrix = trans.valueToPixelMatrix
                
                let iconsOffset = dataSet.iconsOffset
                
                // make sure the values do not interfear with the circles
                var valOffset = Int(dataSet.circleRadius * 1.75)
                
                if !dataSet.isDrawCirclesEnabled {
                    valOffset = valOffset / 2
                }
                
                _xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)
                
                for j in stride(from: _xBounds.min, through: min(_xBounds.min + _xBounds.range, _xBounds.max), by: 1) {
                    guard let e = dataSet.entryForIndex(j) else { break }
                    
                    pt.x = CGFloat(e.x)
                    pt.y = CGFloat(e.y * phaseY)
                    pt = pt.applying(valueToPixelMatrix)
                    
                    if (!viewPortHandler.isInBoundsRight(pt.x)) {
                        break
                    }
                    
                    if (!viewPortHandler.isInBoundsLeft(pt.x) || !viewPortHandler.isInBoundsY(pt.y)) {
                        continue
                    }
                    
                    if dataSet.isDrawValuesEnabled {
                        ChartUtils.drawText(
                            context: context,
                            text: formatter.stringForValue(
                                e.y,
                                entry: e,
                                dataSetIndex: i,
                                viewPortHandler: viewPortHandler),
                            point: CGPoint(
                                x: pt.x,
                                y: pt.y - CGFloat(valOffset) - valueFont.lineHeight),
                            align: .center,
                            attributes: [NSAttributedStringKey.font: valueFont, NSAttributedStringKey.foregroundColor: dataSet.valueTextColorAt(j)])
                    }
                    
                    if let icon = e.icon, dataSet.isDrawIconsEnabled {
                        ChartUtils.drawImage(context: context,
                                             image: icon,
                                             x: pt.x + iconsOffset.x,
                                             y: pt.y + iconsOffset.y,
                                             size: icon.size)
                    }
                }
            }
        }
    }
    
    public override func drawExtras(context: CGContext) {}
    
    // Draw circular values
    fileprivate func drawCircles(context: CGContext, startPoint: Int = 0, shaderEnabled: Bool = false) {
        guard
            let dataProvider = dataProvider,
            let lineData = dataProvider.lineData,
            let animator = animator,
            let viewPortHandler = self.viewPortHandler
            else { return }
        
        let phaseY = animator.phaseY
        
        let dataSets = lineData.dataSets
        
        var pt = CGPoint()
        var rect = CGRect()
        
        context.saveGState()
        
        for i in 0 ..< dataSets.count {
            guard let dataSet = lineData.getDataSetByIndex(i) as? ILineChartDataSet else { continue }
            
            if !dataSet.isVisible || !dataSet.isDrawCirclesEnabled || dataSet.entryCount == 0 {
                continue
            }
            
            let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
            let valueToPixelMatrix = trans.valueToPixelMatrix
            
            _xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)
            
            let circleRadius = dataSet.circleRadius
            let circleDiameter = circleRadius * 2.0
            let circleHoleRadius = dataSet.circleHoleRadius
            let circleHoleDiameter = circleHoleRadius * 2.0
            
            let drawCircleHole = dataSet.isDrawCircleHoleEnabled &&
                circleHoleRadius < circleRadius &&
                circleHoleRadius > 0.0
            
            for j in stride(from: max(_xBounds.min, startPoint), through: _xBounds.range + _xBounds.min, by: 1) {
                guard let e = dataSet.entryForIndex(j) else { break }
                
                pt.x = CGFloat(e.x)
                pt.y = CGFloat(e.y * phaseY)
                pt = pt.applying(valueToPixelMatrix)
                
                if (!viewPortHandler.isInBoundsRight(pt.x)) {
                    break
                }
                
                // make sure the circles don't do shitty things outside bounds
                if (!viewPortHandler.isInBoundsLeft(pt.x) || !viewPortHandler.isInBoundsY(pt.y)) {
                    continue
                }
                
                context.setFillColor(dataSet.getCircleColor(atIndex: j)!.cgColor)
                let scaleFactor = (dataSet as? GradientLineChartDataSet)?.circleScaleFactor(atIndex: j) ?? 1
                // scale up the circle if it is min or max
                rect.size.width = circleDiameter * scaleFactor
                rect.size.height = circleDiameter * scaleFactor
                rect.origin.x = pt.x - circleRadius * scaleFactor
                rect.origin.y = pt.y - circleRadius * scaleFactor
                
                context.fillEllipse(in: rect)
                
                if drawCircleHole {
                    let color = ((dataSet as? GradientLineChartDataSet)?.getHoleCircleColor(atIndex: j)?.cgColor) ?? dataSet.circleHoleColor!.cgColor
                    context.setFillColor(color)
                    
                    // The hole rect
                    rect.origin.x = pt.x - circleHoleRadius * scaleFactor
                    rect.origin.y = pt.y - circleHoleRadius * scaleFactor
                    rect.size.width = circleHoleDiameter * scaleFactor
                    rect.size.height = circleHoleDiameter * scaleFactor
                    
                    context.fillEllipse(in: rect)
                }
                
                if shaderEnabled {
                    context.setFillColor(K.Colors.shader)
                    // scale up the circle if it is min or max
                    rect.size.width = circleDiameter * scaleFactor
                    rect.size.height = circleDiameter * scaleFactor
                    rect.origin.x = pt.x - circleRadius * scaleFactor
                    rect.origin.y = pt.y - circleRadius * scaleFactor
                    
                    context.fillEllipse(in: rect)
                }
            }
        }
        
        context.restoreGState()
    }
    
    open override func drawHighlighted(context: CGContext, indices: [Highlight]) {
        guard
            let dataProvider = dataProvider,
            let lineData = dataProvider.lineData,
            let animator = animator
            else { return }
        
        let chartXMax = dataProvider.chartXMax
        
        context.saveGState()
        
        for high in indices {
            guard let set = lineData.getDataSetByIndex(high.dataSetIndex) as? ILineChartDataSet
                , set.isHighlightEnabled
                else { continue }
            
            guard let e = set.entryForXValue(high.x, closestToY: high.y) else { continue }
            
            if !isInBoundsX(entry: e, dataSet: set) {
                continue
            }
            
            context.setStrokeColor(set.highlightColor.cgColor)
            context.setLineWidth(set.highlightLineWidth)
            if set.highlightLineDashLengths != nil {
                context.setLineDash(phase: set.highlightLineDashPhase, lengths: set.highlightLineDashLengths!)
            } else {
                context.setLineDash(phase: 0.0, lengths: [])
            }
            
            let x = high.x // get the x-position
            let y = high.y * Double(animator.phaseY)
            
            if x > chartXMax * animator.phaseX {
                continue
            }
            
            let trans = dataProvider.getTransformer(forAxis: set.axisDependency)
            
            let pt = trans.pixelForValues(x: x, y: y)
            
            high.setDraw(pt: pt)
            
            // draw the lines
            drawHighlightLines(context: context, point: pt, set: set)
            // draw circle indicator
            drawHighlightCircleIndicator(context: context, highlight: high, point: pt, set: set)
        }
        
        context.restoreGState()
    }
    
    public override func drawHighlightLines(context: CGContext, point: CGPoint, set: ILineScatterCandleRadarChartDataSet) {
        guard let viewPortHandler = self.viewPortHandler, set.isVerticalHighlightIndicatorEnabled else { return }
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
    
    func drawHighlightCircleIndicator(context: CGContext, highlight: Highlight, point: CGPoint, set: ILineChartDataSet) {
        guard let viewPortHandler = viewPortHandler else {return}
        if (!viewPortHandler.isInBoundsRight(point.x)) {
            return
        }
        
        // make sure the circles don't do shitty things outside bounds
        if (!viewPortHandler.isInBoundsLeft(point.x) || !viewPortHandler.isInBoundsY(point.y)) {
            return
        }
        // Draw circle indicator for highlighted value
        if let set = set as? GradientLineChartDataSet, set.circularHighlightIndicatorEnabled, let entry = dataProvider?.lineData?.entryForHighlight(highlight) {
            context.saveGState()
            let circleRadius = set.circleRadius * set.circularHighlightMultiplier
            let circleDiameter = circleRadius * 2.0
            
            let rect = CGRect.init(x: point.x - circleRadius, y: point.y - circleRadius, width: circleDiameter, height: circleDiameter)
            context.setFillColor(UIColor.gradientColor(gradients: K.Colors.gradients, position: CGFloat(entry.y))!.cgColor)
            context.fillEllipse(in: rect)
            
            context.restoreGState()
        }
    }
    
    func drawShader(context: CGContext) {
        guard let data = dataProvider?.lineData as? GradientLineChartData,
            let _ = data.chartView?.valuesToHighlight(),
            let highLight = data.chartView?.lastHighlighted,
            let entry = data.entryForHighlight(highLight),
            let set = dataProvider?.lineData?.dataSets[highLight.dataSetIndex] as? LineChartDataSet else { return }
        drawShadedLine(context: context, point: CGPoint(x: entry.x, y: entry.y), set: set)
        drawCircles(context: context, startPoint: set.entryIndex(entry: entry), shaderEnabled: true)
    }
    
    func drawMarker(context: CGContext, xValue: Double) {
        guard let viewPortHandler = viewPortHandler, let matrix = dataProvider?.getTransformer(forAxis: .left).valueToPixelMatrix, let dataSets = dataProvider?.lineData?.dataSets else {
            return
        }
        for dataSet in dataSets {
            if let dataSet = dataSet as? GradientLineChartDataSet, let yValue = interpolate(xValue: xValue, dataSet: dataSet) {
                var point = CGPoint(x: xValue, y: yValue)
                point = point.applying(matrix)
                if !viewPortHandler.isInBounds(x: point.x, y: point.y) {
                    continue
                }
                if let gradients = dataSet.gradients, let color = UIColor.gradientColor(gradients: gradients, position: CGFloat(yValue)) {
                    ChartUtils.drawText(context: context, text: String(format: "%1.0f%% Excellent", yValue), point: point, align: .left, attributes: [NSAttributedStringKey.foregroundColor : color])
                }
            }
        }
    }
    
    func drawShadedLine(context: CGContext, point: CGPoint, set: LineChartDataSet) {
        guard let viewPortHandler = viewPortHandler else { return }
        if let path = pathCopy?.copy(strokingWithWidth: set.lineWidth, lineCap: .butt, lineJoin: .miter, miterLimit: 10) {
            let pt = dataProvider!.getTransformer(forAxis: set.axisDependency).pixelForValues(x: Double(point.x), y: Double(point.y) * animator!.phaseY)
            // shade right side
            context.saveGState()
            context.addRect(CGRect(x: max(pt.x, viewPortHandler.contentLeft), y: viewPortHandler.contentBottom, width: viewPortHandler.contentRight, height: viewPortHandler.contentTop - viewPortHandler.contentBottom + K.Highlighter.offset))
            context.clip()
            context.beginPath()
            context.addPath(path)
            context.setFillColor(K.Colors.shader)
            context.drawPath(using: .fill)
            
            context.restoreGState()
        }
    }
    
    internal func drawGradientLine(context : CGContext, dataSet: ILineChartDataSet, spline: CGPath, matrix: CGAffineTransform) {
        guard let dataSet = dataSet as? GradientLineChartDataSet, dataSet.gradientEnabled, let viewPortHandler = viewPortHandler, let gradients = dataSet.gradients else {
            return
        }
        context.saveGState()
        let gradientPath = spline.copy(strokingWithWidth: dataSet.lineWidth, lineCap: .butt, lineJoin: .miter, miterLimit: 10)
        context.addPath(gradientPath)
        context.drawPath(using: .fill)
        let gradientStart = CGPoint(x: 0, y: viewPortHandler.contentBottom)
        let gradientEnd   = CGPoint(x: 0, y: viewPortHandler.contentTop)
        var gradientLocations : [CGFloat] = []
        var gradientColors : [CGFloat] = []
        var cRed : CGFloat = 0
        var cGreen : CGFloat = 0
        var cBlue : CGFloat = 0
        var cAlpha : CGFloat = 0
        
        var cColor = dataSet.colors[0]
        
        for i in 0..<gradients.count {
            var positionLocation = CGPoint(x: 0, y: gradients[i].position)
            positionLocation = positionLocation.applying(matrix)
            let normPositionLocation = (positionLocation.y - gradientStart.y) / (gradientEnd.y - gradientStart.y)
            if (normPositionLocation < 0) {
                gradientLocations.append(0)
            } else if (normPositionLocation > 1) {
                gradientLocations.append(1)
            } else {
                gradientLocations.append(normPositionLocation)
            }
            
            cColor = gradients[i].color
            if cColor.getRed(&cRed, green: &cGreen, blue: &cBlue, alpha: &cAlpha) {
                gradientColors += [cRed, cGreen, cBlue, cAlpha]
            }
        }
        
        //Define gradient
        var baseSpace: CGColorSpace? = CGColorSpaceCreateDeviceRGB()
        var gradient : CGGradient?
        gradient = CGGradient(colorSpace: baseSpace!,
                              colorComponents: gradientColors,
                              locations: gradients.count > 1 ? gradientLocations : nil,
                              count: gradientColors.count / 4)
        baseSpace = nil
        
        //Draw gradient path
        guard gradient != nil else {
            return
        }
        context.beginPath()
        context.addPath(gradientPath)
        context.clip()
        context.drawLinearGradient(gradient!, start: gradientStart, end: gradientEnd, options: CGGradientDrawingOptions(rawValue: 0))
        gradient = nil
        context.restoreGState()
    }
    
    /// - returns: `true` if the DataSet values should be drawn, `false` if not.
    internal func shouldDrawValues(forDataSet set: IChartDataSet) -> Bool {
        return set.isVisible && (set.isDrawValuesEnabled || set.isDrawIconsEnabled)
    }
}

extension BarLineScatterCandleBubbleRenderer {
    /// Calculates and returns the x-bounds for the given DataSet in terms of index in their values array.
    /// This includes minimum and maximum visible x, as well as range.
    func xBounds(chart: BarLineScatterCandleBubbleChartDataProvider,
                 dataSet: IBarLineScatterCandleBubbleChartDataSet,
                 animator: Animator?) -> XBounds {
        return XBounds(chart: chart, dataSet: dataSet, animator: animator)
    }
    
    /// Checks if the provided entry object is in bounds for drawing considering the current animation phase.
    func isInBoundsX(entry e: ChartDataEntry, dataSet: IBarLineScatterCandleBubbleChartDataSet) -> Bool {
        let entryIndex = dataSet.entryIndex(entry: e)
        
        if Double(entryIndex) >= Double(dataSet.entryCount) * (animator?.phaseX ?? 1.0) {
            return false
        } else {
            return true
        }
    }
}

private extension GradientLineChartRenderer {
    func interpolate(xValue: Double, dataSet: LineChartDataSet) -> Double? {

        let phaseY = animator?.phaseY ?? 1
        for i in 0..<dataSet.entryCount {
            if dataSet.values[i].x >= xValue {
                let nextIndex = i + 1 < dataSet.entryCount ? i + 1 : i
                let cur = dataSet.values[i]
                let next = dataSet.values[nextIndex]
                
                // return linear interpolation
                return abs((xValue - cur.x) / (next.x - cur.x) * (next.y * phaseY - cur.y * phaseY) + cur.y * phaseY)
            }
        }
        return nil
    }
    
}

