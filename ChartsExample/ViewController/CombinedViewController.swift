//
//  CombinedViewController.swift
//  ChartsExample
//
//  Created by Vincent Ngo on 10/25/17.
//  Copyright © 2017 Vincent Ngo. All rights reserved.
//

import UIKit
import Charts
class CombinedViewController: UIViewController {
    @IBOutlet weak var chartView: StackableChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initStackableChart()
        initConditionChart()
    }
    
    private func initStackableChart() {
        let dates = Date().oneMonthArray()
        var dateSet = [[Double]]()
        for _ in 0...2 {
            dateSet.append(dates)
        }
        
        var dataSets = [StackableChartDataSet]()
        for xAxisValues in dateSet {
            var xEntries = [StackableChartDataEntry]()
            for xValue in xAxisValues {
                let entry = StackableChartDataEntry(x: xValue, y: 50, size: 10)
                entry.highlightedIcon = UIImage(named: "icon")
                entry.icon = UIImage(named: "icon")
                entry.highlightedMultipler = 1.5
                //                entry.timeSpan = 450 // in minute
                entry.label = "test"
                xEntries.append(entry)
            }
            // todo add label
            let set = StackableChartDataSet(values: xEntries, label: "Bubble")
            set.setColor(UIColor.white)
            set.drawValuesEnabled = false
            set.drawIconsEnabled = false
            
            //scheduleTime
            xEntries = [StackableChartDataEntry]()
            for xValue in xAxisValues {
                let entry = StackableChartDataEntry(x: xValue , y: 50, size: 15)
                entry.strokeColor = UIColor.black
                xEntries.append(entry)
            }
            let scheduled = StackableChartDataSet(values: xEntries, label: "")
            scheduled.setColor(UIColor.black.withAlphaComponent(0.5))
            set.scheduledDataSet = scheduled
            dataSets.append(set)
        }
        
        chartView.setStackableDataSets(dataSets: dataSets)
    }
    
    private func initConditionChart() {
        let dateArray = Date().oneMonthArray();
        var entries = [ChartDataEntry]()
        for time in dateArray {
            entries.append(ChartDataEntry(x: time, y: Double(arc4random_uniform(100))))
        }
        
        let set1 = GradientLineChartDataSet(values: entries, label: "CONDITION")
        set1.highlightEnabled = false
        set1.drawIconsEnabled = false
        set1.drawValuesEnabled = false
        set1.drawCirclesEnabled = false
        set1.lineWidth = 2.0
        set1.circleRadius = 3.0
        set1.gradients = K.Colors.gradients
        set1.mode = .horizontalBezier
        set1.valueColors = [UIColor.white]
        
        // date is in minute from timeIntervalSinceReferenceDate
        chartView.setLineChartDataSet(dataSet: set1)
    }
}
