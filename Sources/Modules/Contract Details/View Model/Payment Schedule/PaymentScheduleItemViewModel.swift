//
//  PaymentScheduleItemViewModel.swift
//  ForwardLeasing
//

import UIKit

struct PaymentScheduleItemViewModel {
  // MARK: - Properties
  
  var statusTitle: String? {
    return status.title
  }
  
  var statusColor: UIColor {
    return status.color
  }
  
  var paymentDate: String {
    let dateString = DateFormatter.dayMonthDisplayable.string(from: scheduleItem.paymentDueDate)
    return R.string.contractDetails.paymentDate(dateString)
  }
  
  var paymentPrice: String? {
    return scheduleItem.paymentLeasingSum.priceString()
  }
  
  var residualPrice: String? {
    return residualSum.priceString()
  }
  
  var isMuted: Bool {
    return status == .paid
  }
  
  var isStatusHidden: Bool {
    return status == .future
  }
  
  var isOverdueHidden: Bool {
    return !scheduleItem.paymentOverdue
  }
  
  var overduePrice: String? {
    guard let overdueSum = scheduleItem.paymentDetails.first(where: { $0.type == .penalty })?
            .paymentSum.priceString(withSymbol: false) else { return nil }
    return R.string.contractDetails.paymentFine(overdueSum)
  }
  
  private let scheduleItem: PaymentScheduleItem
  private let status: PaymentScheduleItemStatus
  private let residualSum: Decimal
  
  // MARK: - Init
  
  init(scheduleItem: PaymentScheduleItem, status: PaymentScheduleItemStatus,
       residualSum: Decimal) {
    self.scheduleItem = scheduleItem
    self.status = status
    self.residualSum = residualSum
  }
}
