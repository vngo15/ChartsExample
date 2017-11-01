//
//  WaterIntakeViewController.swift
//  ChartsExample
//
//  Created by Vincent Ngo on 10/31/17.
//  Copyright © 2017 Vincent Ngo. All rights reserved.
//

import UIKit
import Charts
class WaterIntakeViewController: UIViewController {
    @IBOutlet weak var chartView: WaterIntakeChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initWaterChart()
        initConditionChart()
    }
    
    private func initWaterChart() {
        let dates = Date().oneMonthArray()
        // Time is in minutes from reference day
        var xEntries = [WaterIntakeChartDataEntry]()
        for xValue in dates {
            var entry = WaterIntakeChartDataEntry(x: xValue, y: 50, size: 5, count: Double(arc4random_uniform(4) + 1))
            entry.highlightedMultipler = 1.4
            entry.colors = [UIColor.white, UIColor.blue]
            xEntries.append(entry)
            //create multiple data on the same day
            entry = WaterIntakeChartDataEntry(x: xValue + 280, y: 50, size: 5, count: Double(arc4random_uniform(4) + 1))
            entry.highlightedMultipler = 1.4
            entry.colors = [UIColor.white, UIColor.blue]
            xEntries.append(entry)
            entry = WaterIntakeChartDataEntry(x: xValue + 560, y: 50, size: 5, count: Double(arc4random_uniform(4) + 1))
            entry.highlightedMultipler = 1.4
            entry.colors = [UIColor.white, UIColor.blue]
            xEntries.append(entry)
        }
        let set = WaterIntakeChartDataSet(values: xEntries)
        set.drawValuesEnabled = false
        chartView.setWaterIntake(dataSet: set)
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
