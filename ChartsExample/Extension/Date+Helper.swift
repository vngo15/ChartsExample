//
//  Date.swift
//  ChartsExample
//
//  Created by Vincent Ngo on 10/19/17.
//  Copyright © 2017 Vincent Ngo. All rights reserved.
//

import UIKit

extension Date {
    var isToday: Bool {
        let calendar = Calendar(identifier: .gregorian)
        return calendar.isDateInToday(self)
    }
    
    var startOfDate: Date {
        let calendar = Calendar(identifier: .gregorian)
        return calendar.startOfDay(for: self)
    }
    
    func oneMonthBefore() -> Date {
        let calendar = Calendar(identifier: .gregorian)
        var offsetComponent = DateComponents()
        offsetComponent.month = -1
        return calendar.date(byAdding: offsetComponent, to: self)!
    }
    
    func oneMonthArray() -> Array<Double> {
        var array = Array<Double>()
        var second = oneMonthBefore().timeIntervalSinceReferenceDate
        let now = timeIntervalSinceReferenceDate
        repeat {
            array.append(second / 60)
            second += 86400
        } while second <= now
        return array
    }
    
    func toString(format: String) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}
