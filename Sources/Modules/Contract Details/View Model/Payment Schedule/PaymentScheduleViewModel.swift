//
//  PaymentScheduleViewModel.swift
//  ForwardLeasing
//

import Foundation

protocol PaymentScheduleViewModelDelegate: class {
  func paymentScheduleViewModelDidRequestToLayoutSuperview(_ viewModel: PaymentScheduleViewModel)
}

class PaymentScheduleViewModel {
  // MARK: - Properties
  
  weak var delegate: PaymentScheduleViewModelDelegate?
  
  var itemViewModels: [PaymentScheduleItemViewModel] {
    var residualSum = contract.productInfo.leasingSum ?? 0
    return contract.contractInfo?.paymentSchedule.map { item in
      residualSum -= item.paymentLeasingSum
      return makeScheduleItemViewModel(item: item, residualSum: residualSum)
    } ?? []
  }
  
  var firstPaymentItemIndex: Int {
    return max(secondPaymentItemIndex - 1, 0)
  }
  
  var secondPaymentItemIndex: Int {
    if contract.contractInfo?.remainsSum.isZero == true { return (contract.contractInfo?.paymentSchedule.count ?? 2) - 1 }
    return max(contract.contractInfo?.paymentSchedule.firstIndex { $0.paymentDueDate
                == contract.contractInfo?.nextPaymentDate } ?? 0, 1)
  }
  
  var remainingPaymentsTitle: String? {
    guard let nextPaymentDate = contract.contractInfo?.nextPaymentDate else { return nil }
    let payments = contract.contractInfo?.paymentSchedule.filter { $0.paymentDueDate >= nextPaymentDate } ?? []
    let price = payments.reduce(0) { $0 + $1.paymentAmount }.priceString() ?? ""
    
    return R.string.contractDetails.remainingPaymentsTitle(R.string.plurals.remainingPayments(count: payments.count), price)
  }
  
  var exchangePrice: Decimal? {
    return contract.productInfo.upgradePayment
  }
  
  var exchangeIndex: Int? {
    return contract.productInfo.earlyUpgradePaymentsCount
  }
  
  private let contract: LeasingEntity
  
  // MARK: - Init
  
  init(contract: LeasingEntity) {
    self.contract = contract
  }
  
  // MARK: - Public methods
  
  func layoutSuperview() {
    delegate?.paymentScheduleViewModelDidRequestToLayoutSuperview(self)
  }
  
  // MARK: - Private methods
  
  private func makeScheduleItemViewModel(item: PaymentScheduleItem, residualSum: Decimal) -> PaymentScheduleItemViewModel {
    return PaymentScheduleItemViewModel(scheduleItem: item, status: item.status(for: contract.contractInfo?.nextPaymentDate),
                                        residualSum: residualSum)
  }
}

// MARK: - CommonTableCellViewModel

extension PaymentScheduleViewModel: CommonTableCellViewModel {
  var tableCellIdentifier: String {
    return PaymentsScheduleCell.reuseIdentifier
  }
}
