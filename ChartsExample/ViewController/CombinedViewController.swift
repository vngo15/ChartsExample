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
        let dates = Date().oneMonthArray()
        var dateSet = [[Double]]()
        for _ in 0...2 {
            dateSet.append(dates)
        }
        chartView.setStackableDataSets(xAxisSet: dateSet)
        
        let dateArray = Date().oneMonthArray();
        var entries = Array<ChartDataEntry>()
        for time in dateArray {
            entries.append(ChartDataEntry(x: time, y: Double(arc4random_uniform(100))))
        }
        // date is in minute from timeIntervalSinceReferenceDate
        chartView.setLineChartData(entries: entries)
    }
}
