//
//  LeasingContractInfo.swift
//  ForwardLeasing
//

import UIKit

struct PaymentDetail: Codable {
  enum PaymentDetailType: String, Codable {
    case leasing = "LEASING", penalty = "PENALTY", comission = "COMMISSION", lastPay = "LAST_PAY"
  }
  
  let paymentSum: Decimal
  let type: PaymentDetailType
}

enum PaymentScheduleItemStatus {
  case paid, current, overdue, last, future
  
  var title: String? {
    switch self {
    case .paid:
      return R.string.contractDetails.paymentStatusPaid()
    case .current:
      return R.string.contractDetails.paymentStatusCurrent()
    case .overdue:
      return R.string.contractDetails.paymentStatusOverdue()
    case .last:
      return R.string.contractDetails.paymentStatusLast()
    case .future:
      return nil
    }
  }
  
  var color: UIColor {
    switch self {
    case .paid:
      return .shade70
    case .current:
      return .access
    case .overdue:
      return .error
    case .last:
      return .base1
    case .future:
      return .clear
    }
  }
}

struct PaymentScheduleItem: Codable {
  enum CodingKeys: String, CodingKey {
    case paymentNumber, paymentDueDate, paymentDate, paymentAmount,
         paymentOverdue, returnUpgCommission, paymentDetails
  }
  
  let paymentNumber: Int
  let paymentDueDate: Date
  let paymentDate: Date?
  let paymentAmount: Decimal
  let paymentOverdue: Bool
  let returnUpgCommission: Decimal
  let paymentDetails: [PaymentDetail]
  
  func status(for nextPaymentDate: Date?) -> PaymentScheduleItemStatus {
    if paymentOverdue {
      return .overdue
    } else if paymentDueDate == nextPaymentDate {
      return .current
    } else if let nextPaymentDate = nextPaymentDate,
              paymentDueDate < nextPaymentDate {
      return .paid
    } else if paymentDetails.contains(where: { $0.type == .lastPay }) {
      return .last
    } else {
      return .future
    }
  }
  
  var paymentLeasingSum: Decimal {
    return paymentDetails.first { $0.type == .leasing }?.paymentSum ?? 0
  }
}

struct LeasingContractInfo: Codable {
  enum CodingKeys: String, CodingKey {
    case nextPaymentSum, nextPaymentDate, payedSum, remainsSum,
         buyoutSum, overduePenalty, paymentSchedule, paymentsToFreeUpgrade, upgradeReturnEnabled
  }
  
  let nextPaymentSum: Decimal
  let nextPaymentDate: Date
  let payedSum: Decimal
  let remainsSum: Decimal
  let buyoutSum: Decimal?
  let overduePenalty: Decimal?
  let paymentsToFreeUpgrade: Int
  let upgradeReturnEnabled: Bool
  private(set) var paymentSchedule: [PaymentScheduleItem] = []

  var successSegmentsCount: Int {
    return paymentSchedule.reduce(0) { acc, item -> Int in
      let successResult: Int = item.status(for: nextPaymentDate) == .paid ? 1 : 0
      return acc + successResult
    }
  }

  var failureSegmentsCount: Int {
    return paymentSchedule.reduce(0) { acc, item -> Int in
      let failureResult: Int = item.status(for: nextPaymentDate) == .overdue ? 1 : 0
      return acc + failureResult
    }
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    nextPaymentSum = try container.decode(Decimal.self, forKey: .nextPaymentSum)
    nextPaymentDate = try container.decode(Date.self, forKey: .nextPaymentDate)
    payedSum = try container.decode(Decimal.self, forKey: .payedSum)
    remainsSum = try container.decode(Decimal.self, forKey: .remainsSum)
    buyoutSum = try container.decodeIfPresent(Decimal.self, forKey: .buyoutSum)
    paymentsToFreeUpgrade = try container.decode(Int.self, forKey: . paymentsToFreeUpgrade)
    overduePenalty = try container.decodeIfPresent(Decimal.self, forKey: .overduePenalty)
    upgradeReturnEnabled = try container.decodeIfPresent(Bool.self, forKey: .upgradeReturnEnabled) ?? false
    self.paymentSchedule = try container.decodeIfPresent([PaymentScheduleItem].self, forKey: .paymentSchedule) ?? []
  }
}
