//
//  ViewController.swift
//  ChartsExample
//
//  Created by Vincent Ngo on 10/19/17.
//  Copyright © 2017 Vincent Ngo. All rights reserved.
//

import UIKit
import Charts

class ConditionViewController: UIViewController {
    @IBOutlet weak var chartView: ConditionChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dateArray = Date().oneMonthArray();
        var entries = Array<ChartDataEntry>()
        for time in dateArray {
            entries.append(ChartDataEntry(x: time, y: Double(arc4random_uniform(100))))
        }
        // date is in minute from timeIntervalSinceReferenceDate
        chartView.setDataEntry(entries: entries)
    }
}
