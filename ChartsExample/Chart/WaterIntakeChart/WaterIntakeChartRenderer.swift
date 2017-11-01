//
//  WaterIntakeChartRenderer.swift
//  ChartsExample
//
//  Created by Vincent Ngo on 10/31/17.
//  Copyright © 2017 Vincent Ngo. All rights reserved.
//

import UIKit
import Charts

class WaterIntakeChartRenderer: BubbleChartRenderer {
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
        context.saveGState()
        for j in stride(from: xBounds.min, through: xBounds.range + xBounds.min, by: 1) {
            guard let entry = dataSet.entryForIndex(j) as? WaterIntakeChartDataEntry else { continue }
            let rect = getRect(forEntry: entry, animator: animator, transform: valueToPixelMatrix)
            
            if !viewPortHandler.isInBoundsTop(rect.origin.y + rect.height)
                || !viewPortHandler.isInBoundsBottom(rect.origin.y) || !viewPortHandler.isInBoundsLeft(rect.origin.x + rect.width) {
                continue
            } else if !viewPortHandler.isInBoundsRight(rect.origin.x) {
                break
            }
            
            var alpha: CGFloat = 1
            // check if it is highlighted, if it is, then change the alpha of the data
            if let data = dataProvider.bubbleData as? WaterIntakeChartData {
                alpha = data.isDataHighlighted ? K.Colors.shaderAlpha : 1.0
            }
            context.setAlpha(alpha)
            drawEntry(context: context, entry: entry, rect: rect, alpha: alpha, viewPortHandler: viewPortHandler)
        }
        context.restoreGState()
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
                let dataSet = bubbleData.getDataSetByIndex(high.dataSetIndex) as? WaterIntakeChartDataSet,
                dataSet.isHighlightEnabled
                else { continue }
            let transform = dataProvider.getTransformer(forAxis: dataSet.axisDependency).valueToPixelMatrix
            guard let entry = dataSet.entryForXValue(high.x, closestToY: high.y) as? WaterIntakeChartDataEntry else { continue }
            
            // Highlight all in the same day
            for sEntry in dataSet.values.sameDayEntries(fromEntry: entry) {
                if !isInBoundsX(entry: sEntry, dataSet: dataSet) { continue }

                let rect = getRect(forEntry: sEntry, animator: animator, transform: transform, sizeMultiplier: 1)
                if !viewPortHandler.isInBoundsTop(rect.origin.y + rect.height)
                    || !viewPortHandler.isInBoundsBottom(rect.origin.y - rect.height) || !viewPortHandler.isInBoundsLeft(rect.origin.x + rect.width){
                    continue
                } else if !viewPortHandler.isInBoundsRight(rect.origin.x) {
                    break
                }
                
                drawEntry(context: context, entry: sEntry, rect: rect, alpha: 1, viewPortHandler: viewPortHandler)
            }
            
            // highlight the curent selected
            if !isInBoundsX(entry: entry, dataSet: dataSet) { continue }
            let rect = getRect(forEntry: entry, animator: animator, transform: transform, sizeMultiplier: entry.highlightedMultipler)
            high.setDraw(x: rect.origin.x + rect.width / 2, y: rect.origin.y + rect.height / 2)
            
            if !viewPortHandler.isInBoundsTop(rect.origin.y + rect.height)
                || !viewPortHandler.isInBoundsBottom(rect.origin.y - rect.height) || !viewPortHandler.isInBoundsLeft(rect.origin.x + rect.width){
                continue
            } else if !viewPortHandler.isInBoundsRight(rect.origin.x) {
                break
            }
         
            drawEntry(context: context, entry: entry, rect: rect, alpha: 1, viewPortHandler: viewPortHandler)
        }
        context.restoreGState()
    }
}

private extension WaterIntakeChartRenderer {
    private func drawEntry(context: CGContext,
                           entry: WaterIntakeChartDataEntry,
                           rect: CGRect,
                           alpha: CGFloat,
                           viewPortHandler: ViewPortHandler) {
        guard let color = entry.colors.first else { return }
        context.setAlpha(alpha)
        color.setFill()
        let path = UIBezierPath(roundedRect: rect, cornerRadius: rect.width)
        path.fill()
        
        // applying gradient
        if let gradient = entry.colors.gradient() {
            context.addPath(path.cgPath)
            context.clip()
            context.drawLinearGradient(gradient,
                                       start: CGPoint(x: rect.origin.x, y: rect.origin.y),
                                       end: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.height),
                                       options: CGGradientDrawingOptions(rawValue: 0))
            context.resetClip()
            context.clip(to: viewPortHandler.contentRect)
        }
    }
    
    private func getRect(forEntry entry: WaterIntakeChartDataEntry, animator: Animator, transform: CGAffineTransform, sizeMultiplier: CGFloat = 1.0) -> CGRect {
        let phaseY = animator.phaseY
        let shapeWidth: CGFloat = entry.size
        let shapeXHalf = shapeWidth / 2 // offset for center
        var pointBuffer = CGPoint()
        pointBuffer.y = CGFloat(entry.y * phaseY)
        pointBuffer.x = CGFloat(entry.x)
        pointBuffer = pointBuffer.applying(transform)
        let initialValue = pointBuffer.y
        pointBuffer.y = CGFloat((entry.y + entry.normalizedHeight) * phaseY)
        pointBuffer.x = CGFloat(entry.x)
        pointBuffer = pointBuffer.applying(transform)
        let shapeHeight = abs(pointBuffer.y - initialValue)
        let shapeYHalf = shapeHeight / 2.0 // offset for center
        
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
