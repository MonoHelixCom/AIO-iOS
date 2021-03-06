//
//  DateValueFormatter.swift
//  DataFeeds
//
//  Created by Paula Petcu on 9/9/16.
//  Copyright © 2016 monohelixlabs. All rights reserved.
//

import Foundation
import Charts

class DateValueFormatter: NSObject, IAxisValueFormatter {
    
    let dateFormatter = DateFormatter()
    let dateTimePeriodFormatterDateFormat = "MMM dd YYYY HH:mm:ss"
    let timePeriodFormatterDateFormat = "HH:mm:ss"
    let datePeriodFormatterDateFormat = "MMM dd"
    
    init(granularity: String) {
        
        switch granularity {
        case "date":
            dateFormatter.dateFormat = datePeriodFormatterDateFormat
        case "datetime":
            dateFormatter.dateFormat = dateTimePeriodFormatterDateFormat
        case "time":
            dateFormatter.dateFormat = timePeriodFormatterDateFormat
        default:
            dateFormatter.dateFormat = dateTimePeriodFormatterDateFormat
        }
        
        super.init()
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return dateFormatter.string(from: Date(timeIntervalSince1970: value))
    }
    
}
