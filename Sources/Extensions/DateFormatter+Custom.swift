//
//  DateFormatter+CustomISO8601.swift
//  ForwardLeasing
//

import Foundation

private extension Constants {
  static let dayMonthYearISO = "yyyy-MM-dd"
  static let dateAndTimeISO = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
  static let dateAndTimeISOMSK = "yyyy-MM-dd'T'HH:mm:ss"
  static let dateAndTimeISOMicroseconds = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZZZZZ"
  static let dateAndTimeISOMillisecondsTZ = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ'['VV']'"
  static let dateAndTimeISOMicrosecondsMSK = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
  static let dateAndTimeISOMillisecondsMSK = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
  static let dayMonthYearDisplayable = "d MMMM yyyy"
  static let dayMonthYearDocument = "dd.MM.yyyy"
  static let dayMonthYearBackend = "yyyy-MM-dd"
  static let dateAndTimeDisplayable = "dd.MM.yyyy HH:mm"
  static let dayMonthDisplayable = "d MMMM"
  static let monthOnlyDisplayable = "MMMM"
  static let standAloneMonthOnly = "LLLL"
  static let timeOnlyDisplayable = "HH:mm"
}

extension DateFormatter {
  static let dateAndTimeISO = dateFormatterWithLocalTimezone(dateFormat: Constants.dateAndTimeISO)
  static let dayMonthYearISO = dateFormatterWithLocalTimezone(dateFormat: Constants.dayMonthYearISO)
  static let dateAndTimeISOMicroseconds = dateFormatterWithLocalTimezone(dateFormat: Constants.dateAndTimeISOMicroseconds)
  static let dateAndTimeISOMillisecondsTZ = dateFormatterWithLocalTimezone(dateFormat: Constants.dateAndTimeISOMillisecondsTZ)
  static let dateAndTimeISOMSK = dateFormatterWithMSKTimezone(dateFormat: Constants.dateAndTimeISOMSK)
  static let dateAndTimeISOMicrosecondsMSK = dateFormatterWithLocalTimezone(dateFormat: Constants.dateAndTimeISOMicrosecondsMSK)
  static let dateAndTimeISOMillisecondsMSK = dateFormatterWithLocalTimezone(dateFormat: Constants.dateAndTimeISOMillisecondsMSK)
  static let dayMonthYearDisplayable = dateFormatterWithLocalTimezone(dateFormat: Constants.dayMonthYearDisplayable)
  static let dayMonthYearDocument = dateFormatterWithLocalTimezone(dateFormat: Constants.dayMonthYearDocument)
  static let dateAndTimeDisplayable = dateFormatterWithLocalTimezone(dateFormat: Constants.dateAndTimeDisplayable)
  static let dayMonthYearBackend = dateFormatterWithLocalTimezone(dateFormat: Constants.dayMonthYearBackend)
  static let monthOnlyDisplayable = dateFormatterWithLocalTimezone(dateFormat: Constants.monthOnlyDisplayable)
  static let standAloneMonthOnly = dateFormatterWithLocalTimezone(dateFormat: Constants.standAloneMonthOnly)
  static let dayMonthDisplayable = dateFormatterWithLocalTimezone(dateFormat: Constants.dayMonthDisplayable)
  static let timeOnlyDisplayable = dateFormatterWithLocalTimezone(dateFormat: Constants.timeOnlyDisplayable)
  
  private static func dateFormatterWithLocalTimezone(dateFormat: String?) -> DateFormatter {
    return defaultFormatter(withFormat: dateFormat)
  }

  private static func dateFormatterWithMSKTimezone(dateFormat: String?) -> DateFormatter {
    let seconds = 3 * 60 * 60
    return defaultFormatter(withFormat: dateFormat, timeZone: TimeZone(secondsFromGMT: seconds))
  }

  private static func defaultFormatter(withFormat format: String?, timeZone: TimeZone? = .current) -> DateFormatter {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.locale = Constants.appLocale
    formatter.timeZone = timeZone
    formatter.dateFormat = format
    return formatter
  }
}

extension JSONDecoder.DateDecodingStrategy {
  static let customStrategy = custom { decoder throws -> Date in
    let container = try decoder.singleValueContainer()
    let string = try container.decode(String.self)
    if let date = DateFormatter.dateAndTimeISOMicroseconds.date(from: string)
      ?? DateFormatter.dateAndTimeISOMillisecondsMSK.date(from: string)
      ?? DateFormatter.dateAndTimeISOMicrosecondsMSK.date(from: string)
      ?? DateFormatter.dateAndTimeISOMillisecondsTZ.date(from: string)
      ?? DateFormatter.dateAndTimeISO.date(from: string)
      ?? DateFormatter.dateAndTimeISOMSK.date(from: string)
      ?? DateFormatter.dayMonthYearISO.date(from: string) {
      return date
    }
    throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(string)")
  }
}

extension JSONEncoder.DateEncodingStrategy {
  static let dateAndTimeISO = custom { date, encoder throws in
    var container = encoder.singleValueContainer()
    try container.encode(DateFormatter.dateAndTimeISO.string(from: date))
  }
}
