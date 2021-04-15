//
//  PaymentSchedule.swift
//  ForwardLeasing
//

import Foundation

enum SchedulePaymentStatus: String, Codable {
  case paid = "PAID"
  case overdue = "OVERDUE"
  case notPaid = "NOT_PAID"
}

struct PaymentSchedule: Codable {
  let id: String
  let status: SchedulePaymentStatus
  let actualPaymentDate: Date?
  let plannedPaymentDate: Date
  let sum: Amount
  var overdueSum: Amount?
  
  enum CodingKeys: String, CodingKey {
    case id = "paymentId"
    case status = "paymentStatus"
    case actualPaymentDate
    case plannedPaymentDate
    case sum = "paymentSum"
    case overdueSum
  }
}
