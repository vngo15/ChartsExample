//
//  PainGraphViewController.swift
//  ChartsExample
//
//  Created by Ethan Lillie on 11/6/17.
//  Copyright © 2017 Vincent Ngo. All rights reserved.
//

import UIKit
import Charts

class PainGraphViewController: UIViewController {
    @IBOutlet weak var chartView: StackableChartView!
    var painData: [PainData]?

    static func instantiateViewControllerFromStoryboard() -> PainGraphViewController {
        let conditionStoryboard = UIStoryboard(name: "PainGraph", bundle: nil)
        guard let myVC = conditionStoryboard.instantiateInitialViewController() as? PainGraphViewController else {
            fatalError("Expected \(type(of: self))")
        }
        return myVC
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        painData = PainData.mockPainData()

        initPainStackableChart()
        initConditionChart()
    }

    private func initPainStackableChart() {

        guard let painCategoryInstances = painData else {
            fatalError("no pain data loaded")
        }

        var painDataSets = [StackableChartDataSet]()

        for painCategoryInstance in painCategoryInstances {
            var painDataEntries = [StackableChartDataEntry]()
            for painInstance in painCategoryInstance.activities {

                let minutesSinceReferenceDate = painInstance.startTime.timeIntervalSinceReferenceDate / 60

                let entry = StackableChartDataEntry(x: minutesSinceReferenceDate,
                                                    y: 50,
                                                    size: 10)

                switch painInstance.intensity {
                case .none:
                    entry.colors = [UIColor.green]
                case .mild:
                    entry.colors = [UIColor.yellow]
                case .moderate:
                    entry.colors = [UIColor.orange]
                case .bad:
                    entry.colors = [UIColor.orange]
                    entry.halo = true
                    entry.haloColor = UIColor.red.withAlphaComponent(0.5)
                case .severe:
                    entry.colors = [UIColor.red]
                    entry.halo = true
                    entry.haloColor = UIColor.red.withAlphaComponent(0.5)
                }

                painDataEntries.append(entry)
            }

            let painDataSet = StackableChartDataSet(values: painDataEntries,
                                                    label: painCategoryInstance.activityTitle)

            painDataSet.drawValuesEnabled = false
            painDataSet.drawIconsEnabled = false
            painDataSet.legendEnabled = true

            painDataSets.append(painDataSet)
        }

        chartView.setStackableDataSets(dataSets: painDataSets)
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

// Model from chemoWave App:

enum PainIntensity: Int {
    case none, mild, moderate, bad, severe
}


struct PainLog {
    var categoryName: String
    var startTime: Date
    var endTime: Date
    var duration: TimeInterval
    var durationInHours: Double
    var intensity: PainIntensity

//    var lowIntensityInHours: Double
//    var medIntensityInHours: Double
//    var highIntensityInHours: Double
}

class PainData {
    var activityTitle: String
    var activities:[PainLog] = []
    init(title: String) {
        self.activityTitle = title
    }
    convenience init() {
        self.init(title: "")
    }

    class func mockPainData() -> [PainData] {
        let possiblePainCategories = ["Left Shoulder", "Right Shoulder", "Head", "Left Hand", "Right Hand"]

        var painData = [PainData]()

        for painCategory in possiblePainCategories {

            var thisCategoryPainData = PainData(title: painCategory)

            for _ in 1...60 {

                let oneMonthSpan = Date().timeIntervalSince(Date().oneMonthBefore())

                let time = Date().addingTimeInterval(-TimeInterval(arc4random_uniform(UInt32(oneMonthSpan))))

                let painLog = PainLog(categoryName: painCategory,
                                      startTime: time,
                                      endTime: time,
                                      duration: 0,
                                      durationInHours: 0,
                                      intensity: PainIntensity(rawValue: Int(arc4random_uniform(5)))!)

                thisCategoryPainData.activities.append(painLog)
            }

            thisCategoryPainData.activities.sort { $0.startTime.timeIntervalSince($1.startTime) < 0 }

            painData.append(thisCategoryPainData)
        }
        return painData
    }


}
