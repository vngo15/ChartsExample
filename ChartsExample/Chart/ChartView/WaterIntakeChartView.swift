//
//  WaterIntakeChartView.swift
//  ChartsExample
//
//  Created by Vincent Ngo on 10/31/17.
//  Copyright © 2017 Vincent Ngo. All rights reserved.
//

import UIKit
import Charts

class WaterIntakeChartView: CombinedChartView {
    lazy var headerLabel: UILabel? = UILabel()
    let conditionMarker = ConditionChartMarker.viewFromXib() as? ConditionChartMarker
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        initHeader()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        style()
        initHeader()
    }
    
    func setLineChartDataSet(dataSet: GradientLineChartDataSet) {
        if let dataCount = lineData?.dataSets.count, dataCount > 0, let set1 = data?.dataSets[0] as? GradientLineChartDataSet {
            set1.values = dataSet.values
            moveViewToX(set1.xMax)
            data?.notifyDataChanged()
            notifyDataSetChanged()
        } else {
            moveViewToX(dataSet.xMax)
            combinedData?.lineData = GradientLineChartData(dataSets: [dataSet], chartView: self)
        }
    }
    
    func setWaterIntake(dataSet: BubbleChartDataSet) {
        if let data = combinedData?.bubbleData as? WaterIntakeChartData {
            data.contentTopPosition = leftAxis.axisMaximum
            data.contentBottomPosition = leftAxis.axisMinimum + 110
            data.dataSets = [dataSet]
        }
        notifyDataSetChanged()
    }
    
    override func highlightValue(_ highlight: Highlight?, callDelegate: Bool) {
        super.highlightValue(highlight, callDelegate: callDelegate)
        updateHeader(highlight: highlight)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawConditionMarker()
    }
}

private extension WaterIntakeChartView {
    private func style() {
        styleAxis()
        leftAxis.axisMaximum = 700
        
        // init marker
        conditionMarker?.gradients = K.Colors.gradients
        conditionMarker?.chartView = self
        let m = WaterIntakeMarker.viewFromXib()
        m?.chartView = self
        marker = m
            
        // init data
        data = CombinedChartData(dataSet: nil)
        if !(combinedData?.bubbleData is WaterIntakeChartData) {
            combinedData?.bubbleData = WaterIntakeChartData(dataSets: nil, chartView:self)
        }
        
        highlighter = StackableHighlighter(chart: self)
        renderer = StackableCombinedChartRenderer(chart: self, animator: chartAnimator, viewPortHandler: viewPortHandler)
        if let combinedRenderer = renderer as? CombinedChartRenderer {
            combinedRenderer.subRenderers.append(WaterIntakeChartRenderer(dataProvider: self, animator: chartAnimator, viewPortHandler: viewPortHandler))
            combinedRenderer.subRenderers.append(GradientLineChartRenderer(dataProvider: self, animator: chartAnimator, viewPortHandler: viewPortHandler))
        }
    }
    
    private func initHeader() {
        addSubview(headerLabel!)
        headerLabel?.textColor = UIColor.white
        headerLabel?.textAlignment = .center
        headerLabel?.text = "test"
        headerLabel?.backgroundColor = UIColor.blue
        headerLabel?.isHidden = true
    }
    
    private func updateHeader(highlight: Highlight?) {
        if let highlight = highlight, let entry = data?.entryForHighlight(highlight) {
            headerLabel?.isHidden = false
            headerLabel?.frame = CGRect(x: 0, y: 0,width: self.frame.width, height: viewPortHandler.contentTop + K.XAxis.gridLineHeight * 2)
            let date = Date(timeIntervalSinceReferenceDate: entry.x * 60)
            if date.isToday {
                headerLabel?.text = "Today " + date.toString(format: "h:mmaa")!
            } else {
                headerLabel?.text = date.toString(format: "E MM/dd h:mmaa")
            }
            
        } else {
            headerLabel?.isHidden = true
        }
    }
    
    private func drawConditionMarker() {
        guard valuesToHighlight(), let highlight = highlighted.first, let dataSets = lineData?.dataSets, let renderer = renderer as? StackableCombinedChartRenderer, let gRenderer = renderer.gradientLineRenderer() else {
            return
        }
        let optionalContext = UIGraphicsGetCurrentContext()
        guard let context = optionalContext else { return }
        context.addRect(viewPortHandler.contentRect)
        context.clip()
        
        for dataSet in dataSets {
            if let dataSet = dataSet as? GradientLineChartDataSet, let yValue = gRenderer.interpolate(xValue: highlight.x, dataSet: dataSet) {
                var point = CGPoint(x: highlight.x, y: yValue)
                let entry = ChartDataEntry(x: highlight.x, y: yValue)
                let h = Highlight(x: highlight.x, y: yValue, dataSetIndex: -1)
                
                point = point.applying(getTransformer(forAxis: dataSet.axisDependency
                    ).valueToPixelMatrix)
                if !viewPortHandler.isInBounds(x: point.x, y: point.y) {
                    continue
                }
                h.setDraw(pt: point)
                conditionMarker?.refreshContent(entry: entry, highlight: h)
                conditionMarker?.draw(context: context, point: point)
            }
        }
    }
}
