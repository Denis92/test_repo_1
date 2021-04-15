//
//  OccupationData.swift
//  ForwardLeasing
//

import Foundation

struct OccupationData: Codable {
  enum CodingKeys: String, CodingKey {
    case key = "Key"
    case value = "Value"
  }
  let key: String
  let value: String
  
  static func makeDefaultOptions() -> [OccupationData] {
    return [
      OccupationData(key: "COMMERCIAL_EMPLOYEE", value: R.string.passportDataConfirmation.occupationEmployee()),
      OccupationData(key: "BUSINESSMAN", value: R.string.passportDataConfirmation.occupationEnterpreneur()),
      OccupationData(key: "UNEMPLOYED", value: R.string.passportDataConfirmation.occupationUnemployed()),
      OccupationData(key: "RETIRED", value: R.string.passportDataConfirmation.occupationRetired())
    ]
  }
}
