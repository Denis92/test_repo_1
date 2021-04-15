//
//  Date+Additions.swift
//  ForwardLeasing
//

import Foundation

extension Date {
  var fullMonth: String {
    return DateFormatter.monthOnlyDisplayable.string(from: self)
  }

  var fullStandAloneMonth: String {
    return DateFormatter.standAloneMonthOnly.string(from: self)
  }
  
  var dayOfMonth: Int {
    return calendar.component(.day, from: self) ?? 0
  }

  var dateOnly: Date? {
     return calendar.date(from: Calendar.current.dateComponents([.year, .month, .day],
                                                                        from: self))
  }
  
  private var calendar: Calendar {
    return Calendar.current
  }
  
  func date(byAddingDays days: Int) -> Date {
    return calendar.date(byAdding: .day, value: days, to: self) ?? self
  }
}
