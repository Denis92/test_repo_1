//
//  Amount.swift
//  ForwardLeasing
//

import Foundation

struct Amount: Codable {
  let value: NSDecimalNumber
  
  var decimalValue: Decimal {
    return value.decimalValue
  }
  
  var isZero: Bool {
    return decimalValue.isZero
  }
  
  static var zero: Amount {
    return Amount(decimal: 0)
  }
  
  // MARK: - Init
  
  init(decimal: Decimal) {
    value = NSDecimalNumber(decimal: decimal)
  }
  
  init(value: NSDecimalNumber) {
    self.value = value
  }
  
  init(floatLiteral: Double) {
    let decimalValue = Decimal(floatLiteral)
    value = NSDecimalNumber(decimal: decimalValue)
  }
  
  // MARK: - Codable
  
  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let double = try container.decode(Double.self)
    
    guard let decimal = Decimal(string: "\(double)") else {
      throw DecodingError.dataCorruptedError(in: container, debugDescription: "Can't decode decimal value: \(double)")
    }
    value = NSDecimalNumber(decimal: decimal)
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(value.decimalValue)
  }
}

// MARK: - Comparable

extension Amount: Comparable {
  static func < (lhs: Amount, rhs: Amount) -> Bool {
    return lhs.value.decimalValue < rhs.value.decimalValue
  }
}

// MARK: - Equatable

extension Amount: Equatable {}

// MARK: - Operations

extension Amount {
  static func * (lhs: Amount, rhs: Amount) -> Amount {
    return Amount(value: lhs.value.multiplying(by: rhs.value))
  }
  
  static func / (lhs: Amount, rhs: Amount) -> Amount {
    return Amount(value: lhs.value.dividing(by: rhs.value))
  }
  
  static func + (lhs: Amount, rhs: Amount) -> Amount {
    return Amount(value: lhs.value.adding(rhs.value))
  }
  
  static func - (lhs: Amount, rhs: Amount) -> Amount {
    return Amount(value: lhs.value.subtracting(rhs.value))
  }
  
  static func += (lhs: inout Amount, rhs: Amount) {
    lhs = Amount(value: lhs.value.adding(rhs.value))
  }
}

// MARK: - Literal Initialization

extension Amount: ExpressibleByIntegerLiteral {
  init(integerLiteral value: Int) {
    self.init(decimal: Decimal(value))
  }
}
