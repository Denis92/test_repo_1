//
//  AgreementType.swift
//  ForwardLeasing
//

import Foundation

enum AgreementType {
  case registerPersonalData
  case electronicSignature(basketID: String)
  case leasingPersonalData(basketID: String)
  case personalDataAndSubscrptionRules
  
  var rawValue: Int {
    switch self {
    case .registerPersonalData:
      return 0
    case .electronicSignature:
      return 1
    case .leasingPersonalData:
      return 2
    case .personalDataAndSubscrptionRules:
      return 3
    }
  }
}

// MARK: - Equatable
extension AgreementType: Equatable {
  static func == (lhs: Self, rhs: Self) -> Bool {
    return lhs.rawValue == rhs.rawValue
  }
}

// MARK: - Hashable
extension AgreementType: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(rawValue)
  }
}
