//
//  DateOfBirthValidator.swift
//  ForwardLeasing
//

import Foundation

private extension Constants {
  static let minYearsOld = 14
  static let maxYearsOld = 75
}

class DateOfBirthValidator: TextInputValidator {
  override func validate(_ text: String?) throws {
    guard let text = text, !text.isEmpty else {
      throw ValidationError.emptyText
    }
    let formatter = DateFormatter.dayMonthYearDisplayable
    guard let date = formatter.date(from: text) else {
      throw ValidationError.invalidDate
    }
    let yearsSinceBirth = Calendar.current.dateComponents([.year], from: date, to: Date()).year ?? 0
    guard (Constants.minYearsOld ... Constants.maxYearsOld).contains(yearsSinceBirth) else {
      throw ValidationError.invalidDateOfBirth
    }
  }
}
