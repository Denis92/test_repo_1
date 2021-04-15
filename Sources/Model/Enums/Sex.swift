//
//  Sex.swift
//  ForwardLeasing
//

import Foundation

private extension Constants {
  static let passportGenderMale = "МУЖ."
  static let passportGenderFemale = "ЖЕН."
}

enum Sex: String, Codable {
  case male = "MALE", female = "FEMALE"

  init?(passportString: String?) {
    guard let string = passportString else {
      return nil
    }
    switch string {
    case Constants.passportGenderMale:
      self = .male
    case Constants.passportGenderFemale:
      self = .female
    default:
      return nil
    }
  }
}
