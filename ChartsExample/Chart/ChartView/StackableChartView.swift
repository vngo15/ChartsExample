//
//  CombinedChartViewViewController.swift
//  ChartsExample
//
//  Created by Vincent Ngo on 10/25/17.
//  Copyright © 2017 Vincent Ngo. All rights reserved.
//
//  Basically all the combination of StackableChart (SC) and GradientLineChart (GLC)
//  ------------- y = 700 or whatever, defined in StakableChartData.contentTopPosition
//  |           | and leftAxis.axisMaximum
//  |    SC     |
//  |           |
//  ------------- y = 110, defined in StackableChartData.contentBottomPosition
//  |           |
//  |    GLC    |
//  |           |
//  ------------- y = - 10
//

import UIKit
import Charts

class StackableChartView: CombinedChartView {
    lazy var headerLabel: UILabel? = UILabel()
    lazy var conditionMarker = ConditionChartMarker.viewFromXib() as? ConditionChartMarker
    var multipleHighlightEnabled = true
    
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
 
    func setStackableDataSets(dataSets: [StackableChartDataSet]) {
       if let data = combinedData?.bubbleData as? StackableChartData {
            data.contentTopPosition = leftAxis.axisMaximum
            data.contentBottomPosition = leftAxis.axisMinimum + 110
            data.setValueTextColor(UIColor.white)
            data.dataSets = dataSets
//            data.scheduleTimeEnabled = false // disable or enable schedule time, also can set it individually in dataset
        }
        notifyDataSetChanged()
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
    
    override func highlightValue(_ highlight: Highlight?, callDelegate: Bool) {
        super.highlightValue(highlight, callDelegate: callDelegate)
        updateHeader(highlight: highlight)
        
        if multipleHighlightEnabled, let highlight = highlight, let highlights = (highlighter as? StackableHighlighter)?.getHighlights(xValue: highlight.x, x: 0, y: 0) {
            highlightValues(highlights) // highlight multiple values
        }
    }
   
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawConditionMarker()
    }
}

private extension StackableChartView {
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
    
    private func initHeader() {
        addSubview(headerLabel!)
        headerLabel?.textColor = UIColor.white
        headerLabel?.textAlignment = .center
        headerLabel?.text = "test"
        headerLabel?.backgroundColor = UIColor.blue
        headerLabel?.isHidden = true
    }
    
    private func style() {
        styleAxis()
        leftAxis.axisMaximum = 700
        
        // init marker
        conditionMarker?.gradients = K.Colors.gradients
        conditionMarker?.chartView = self
        let marker = ActivityChartMarker.viewFromXib()
        marker?.chartView = self
        self.marker = marker
        
        // init data
        data = CombinedChartData(dataSet: nil)
        if !(combinedData?.bubbleData is StackableChartData) {
            combinedData?.bubbleData = StackableChartData(dataSets: nil, chartView:self)
        }
        highlighter = StackableHighlighter(chart: self)
        renderer = StackableCombinedChartRenderer(chart: self, animator: chartAnimator, viewPortHandler: viewPortHandler)
        if let combinedRenderer = renderer as? CombinedChartRenderer {
            combinedRenderer.subRenderers.append(StackableChartRenderer(dataProvider: self, animator: chartAnimator, viewPortHandler: viewPortHandler))
            combinedRenderer.subRenderers.append(GradientLineChartRenderer(dataProvider: self, animator: chartAnimator, viewPortHandler: viewPortHandler))
        }
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
}
