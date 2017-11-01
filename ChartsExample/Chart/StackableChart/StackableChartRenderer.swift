//
//  StackableChartRenderer.swift
//  ChartsExample
//
//  Created by Vincent Ngo on 10/25/17.
//  Copyright © 2017 Vincent Ngo. All rights reserved.
//

import UIKit
import Charts
class StackableChartRenderer: BubbleChartRenderer {
    open override func drawDataSet(context: CGContext, dataSet: IBubbleChartDataSet) {
        guard
            let dataProvider = dataProvider,
            let viewPortHandler = self.viewPortHandler,
            let animator = animator
            else { return }
        
        let xBounds = XBounds()
        xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)
        let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
        let valueToPixelMatrix = trans.valueToPixelMatrix
        var pointBuffer = CGPoint()
        
        if let sDataSet = dataSet as? StackableChartDataSet, let scheduled = sDataSet.scheduledDataSet {
            // recursive call
            drawDataSet(context: context, dataSet: scheduled)
        }
        
        context.saveGState()
        for j in stride(from: xBounds.min, through: xBounds.range + xBounds.min, by: 1) {
            guard let entry = dataSet.entryForIndex(j) as? StackableChartDataEntry else { continue }
            let rect = getRect(forEntry: entry, animator: animator, transform: valueToPixelMatrix)
            
            if !viewPortHandler.isInBoundsTop(rect.origin.y + rect.height)
                || !viewPortHandler.isInBoundsBottom(rect.origin.y) || !viewPortHandler.isInBoundsLeft(rect.origin.x + rect.width) {
                continue
            }
            
            if !viewPortHandler.isInBoundsRight(rect.origin.x) {
                break
            }
            
            var alpha: CGFloat = 1
            // check if it is highlighted, if it is, then change the alpha of the data
            if let data = dataProvider.bubbleData as? StackableChartData {
                alpha = data.isDataHighlighted ? K.Colors.shaderAlpha : 1.0
            }
            context.setAlpha(alpha)
            if entry.icon != nil {
                ChartUtils.drawImage(context: context,
                                     image: entry.icon!.image(alpha: alpha)!,
                                     x: rect.origin.x + rect.width / 2, // Add offset back from ChartUtils.drawImage
                                     y: rect.origin.y + rect.width / 2, // Add offset back from ChartUtils.drawImage
                                     size: rect.size)
            } else {
                guard let color = entry.colors.first else { continue }
                color.setFill()
                context.setFillColor(color.cgColor)
                let path = UIBezierPath(roundedRect: rect, cornerRadius: rect.height)
                context.addPath(path.cgPath)
                context.fillPath()
                
                // applying gradient
                if let gradient = entry.colors.gradient() {
                    context.addPath(path.cgPath)
                    context.clip()
                    context.drawLinearGradient(gradient,
                                               start: CGPoint(x: rect.origin.x, y: rect.origin.y),
                                               end: CGPoint(x: rect.origin.x + rect.width, y: rect.origin.y),
                                               options: CGGradientDrawingOptions(rawValue: 0))
                    context.resetClip()
                    context.clip(to: viewPortHandler.contentRect)
                }
                
                if let strokeColor = entry.strokeColor {
                    context.addPath(path.cgPath)
                    context.setStrokeColor(strokeColor.cgColor)
                    context.strokePath()
                }
                
            }
        }

        context.restoreGState()
        // Draw label on top of the data set
        var labelOffset = 0.0
        if let data = dataProvider.data as? StackableChartData {
            labelOffset = (data.contentTopPosition - data.contentBottomPosition) / Double(data.dataSetCount) / 4
        } else {
            labelOffset = (dataProvider.chartYMax - dataProvider.chartYMin) / Double(dataProvider.data?.dataSetCount ?? 1) / 4
        }
        pointBuffer.y = CGFloat(dataSet.yMax + labelOffset)
        pointBuffer = pointBuffer.applying(valueToPixelMatrix)
        drawLabel(context: context, x: viewPortHandler.contentLeft + 10.0, y: pointBuffer.y, label: dataSet.label ?? "", font: K.Legend.font, textColor: K.Legend.color)
    }
    
    override func drawHighlighted(context: CGContext, indices: [Highlight]) {
        guard let
            dataProvider = dataProvider,
            let viewPortHandler = self.viewPortHandler,
            let bubbleData = dataProvider.bubbleData,
            let animator = animator
            else { return }

        context.saveGState()
        
        for high in indices {
            guard
                let dataSet = bubbleData.getDataSetByIndex(high.dataSetIndex) as? IBubbleChartDataSet,
                dataSet.isHighlightEnabled
                else { continue }
            
            guard let entry = dataSet.entryForXValue(high.x, closestToY: high.y) as? StackableChartDataEntry else { continue }
            
            if !isInBoundsX(entry: entry, dataSet: dataSet) { continue }
            let transform = dataProvider.getTransformer(forAxis: dataSet.axisDependency).valueToPixelMatrix
            let rect = getRect(forEntry: entry, animator: animator, transform: transform, sizeMultiplier: entry.highlightedMultipler)
            high.setDraw(x: rect.origin.x + rect.width / 2, y: rect.origin.y + rect.height / 2)
            if !viewPortHandler.isInBoundsTop(rect.origin.y + rect.height)
                || !viewPortHandler.isInBoundsBottom(rect.origin.y - rect.height) {
                continue
            }
            
            if !viewPortHandler.isInBoundsLeft(rect.origin.x + rect.width) {
                continue
            }
            
            if !viewPortHandler.isInBoundsRight(rect.origin.x) {
                break
            }
            
            if entry.highlightedIcon != nil {
                ChartUtils.drawImage(context: context,
                                     image: entry.highlightedIcon!,
                                     x: rect.origin.x + rect.width / 2, // Add offset back from ChartUtils.drawImage
                                     y: rect.origin.y + rect.width / 2, // Add offset back from ChartUtils.drawImage
                                     size: rect.size)
            } else { // draw color
                guard let color = entry.colors.first else { continue }
                context.setStrokeColor(color.cgColor)
                let path = UIBezierPath(roundedRect: rect, cornerRadius: rect.height)
                path.fill()
                // applying gradient
                if let gradient = entry.colors.gradient() {
                    context.addPath(path.cgPath)
                    context.clip()
                    context.drawLinearGradient(gradient,
                                               start: CGPoint(x: rect.origin.x, y: rect.origin.y),
                                               end: CGPoint(x: rect.origin.x + rect.width, y: rect.origin.y),
                                               options: CGGradientDrawingOptions(rawValue: 0))
                    context.resetClip()
                }
            }
        }
        context.restoreGState()
    }
    
    private func getRect(forEntry entry: StackableChartDataEntry, animator: Animator, transform: CGAffineTransform, sizeMultiplier: CGFloat = 1.0) -> CGRect {
        let phaseY = animator.phaseY
        let shapeHeight: CGFloat = entry.size
        let shapeYHalf = shapeHeight / 2.0 // offset for center
        var shapeWidth: CGFloat = 0
        var shapeXHalf: CGFloat = 0 // offset for center
        var pointBuffer = CGPoint()
        
        if entry.timeSpan != nil {
            pointBuffer.y = CGFloat(entry.y * phaseY)
            pointBuffer.x = CGFloat(entry.x)
            pointBuffer = pointBuffer.applying(transform)
            let initialValue = pointBuffer.x
            pointBuffer.y = CGFloat(entry.y * phaseY)
            pointBuffer.x = CGFloat(entry.x + entry.timeSpan!)
            pointBuffer = pointBuffer.applying(transform)
            shapeWidth = pointBuffer.x - initialValue
            
        } else {
            shapeWidth = shapeHeight
            shapeXHalf = shapeHeight / 2.0
        }
        
        pointBuffer.x = CGFloat(entry.x)
        pointBuffer.y = CGFloat(entry.y * phaseY)
        pointBuffer = pointBuffer.applying(transform)
        return CGRect(
            x: pointBuffer.x - shapeXHalf * sizeMultiplier,
            y: pointBuffer.y - shapeYHalf * sizeMultiplier,
            width: shapeWidth * sizeMultiplier,
            height: shapeHeight * sizeMultiplier
        )
    }
}

extension Renderer {
    /// Draws the provided label at the given position.
    open func drawLabel(context: CGContext, x: CGFloat, y: CGFloat, label: String, font: NSUIFont, textColor: NSUIColor) {
        ChartUtils.drawText(context: context, text: label, point: CGPoint(x: x, y: y), align: .left, attributes: [NSAttributedStringKey.font: font, NSAttributedStringKey.foregroundColor: textColor])
    }
}

