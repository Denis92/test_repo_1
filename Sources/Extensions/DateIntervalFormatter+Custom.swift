//
//  DateIntervalFormatter+Custom.swift
//  ForwardLeasing
//

import Foundation

extension DateIntervalFormatter {
  static let fullMonthOnlyInterval = intervalFormatter(withDateTemplate: "MMMM")

  private static func intervalFormatter(withDateTemplate dateTemplate: String,
                                        timeZone: TimeZone? = .current) -> DateIntervalFormatter {
    let formatter = DateIntervalFormatter()
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.locale = Constants.appLocale
    formatter.timeZone = timeZone
    formatter.dateTemplate = dateTemplate
    return formatter
  }
}
