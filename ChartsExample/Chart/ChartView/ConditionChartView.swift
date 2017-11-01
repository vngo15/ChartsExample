//
//  ConditionChartView.swift
//  ChartsExample
//
//  Created by Vincent Ngo on 10/19/17.
//  Copyright © 2017 Vincent Ngo. All rights reserved.
//

import UIKit
import Charts
class ConditionChartView: LineChartView {
    var averageLimitLine: ChartLimitLine?
    let gradients = K.Colors.gradients
    lazy var headerLabel: UILabel? = UILabel()
    
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
    
    private func initHeader() {
        addSubview(headerLabel!)
        headerLabel?.textColor = UIColor.white
        headerLabel?.textAlignment = .center
        headerLabel?.text = "test"
        headerLabel?.backgroundColor = UIColor.blue
        headerLabel?.isHidden = true
    }
    
    private func style() {
        renderer = GradientLineChartRenderer(dataProvider: self, animator: chartAnimator, viewPortHandler: viewPortHandler)
        styleAxis()
        
        // Marker
        let marker = ConditionChartMarker.viewFromXib() as? ConditionChartMarker
        marker?.chartView = self
        marker?.gradients = gradients
        
        self.marker = marker
    }
    
    // x axis is in minute from timeIntervalSinceReferenceDate
    func setDataEntry(entries: [ChartDataEntry]) {
        if averageLimitLine != nil {
            leftAxis.removeLimitLine(averageLimitLine!)
        }
        averageLimitLine = ChartLimitLine(limit: entries.average, label: String(format: "Average: %1.f%%", entries.average))
        averageLimitLine?.lineWidth = 1;
        averageLimitLine?.lineDashLengths = [2, 2]
        averageLimitLine?.labelPosition = .leftTop
        averageLimitLine?.lineColor = UIColor.white
        averageLimitLine?.valueTextColor = UIColor.white
        leftAxis.addLimitLine(averageLimitLine!)
        
        if let dataCount = data?.dataSets.count, dataCount > 0{
            let set1 = data!.dataSets[0] as! GradientLineChartDataSet
            set1.values = entries
            moveViewToX(set1.xMax)
            data?.notifyDataChanged()
            notifyDataSetChanged()
        } else {
            let set1 = GradientLineChartDataSet(values: entries, label: "")
            set1.drawIconsEnabled = false
            set1.lineWidth = 2.0
            set1.circleRadius = 3.0
            set1.circleColors = [UIColor.white]
            set1.circleHoleRadius = 2.5
            set1.circleHoleColor = UIColor.white
            set1.drawCirclesEnabled = true
            set1.gradients = gradients
            set1.mode = .horizontalBezier
            set1.valueFormatter = ValueFormatter(chart: self)
            set1.valueColors = [UIColor.white]
            moveViewToX(set1.xMax)
            data = GradientLineChartData(dataSets: [set1], chartView: self)
        }
    }
    
    override func highlightValue(_ highlight: Highlight?, callDelegate: Bool) {
        super.highlightValue(highlight, callDelegate: callDelegate)
        updateHeader(highlight: highlight)
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
