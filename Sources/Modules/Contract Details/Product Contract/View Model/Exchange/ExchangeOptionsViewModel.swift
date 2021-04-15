//
//  ExchangeOptionsViewModel.swift
//  ForwardLeasing
//

import Foundation

protocol ExchangeOptionsViewModelDelegate: class {
  func exchangeOptionsViewModel(_ viewModel: ExchangeOptionsViewModel, didSelectModel model: ModelInfo)
}

class ExchangeOptionsViewModel: CommonCollectionViewModel {
  weak var delegate: ExchangeOptionsViewModelDelegate?
  
  var collectionCellViewModels: [CommonCollectionCellViewModel] {
    return exchangeOptionsItemViewModels
  }
  
  var title: String? {
    guard let priceString = earlyExchangeSum.priceString() else { return nil }
    return R.string.contractDetails.exchangeOptionsTitle(priceString)
  }
  
  var remainingPaymentsText: String {
    return R.string.contractDetails.remainingPaymentsForFreeExchange(R.string.plurals.remainingPayments(count: remainingPayments))
  }
  
  private let earlyExchangeSum: Decimal
  private let remainingPayments: Int
  private let currentMonthPrice: Decimal
  private let models: [ModelInfo]
  private let exchangeOptionsItemViewModels: [ExchangeOptionsItemViewModel]
  
  init(earlyExchangeSum: Decimal, remainingPayments: Int,
       currentMonthPrice: Decimal, models: [ModelInfo]) {
    self.earlyExchangeSum = earlyExchangeSum
    self.remainingPayments = remainingPayments
    self.currentMonthPrice = currentMonthPrice
    self.models = models
    self.exchangeOptionsItemViewModels = models.map { ExchangeOptionsItemViewModel(model: $0,
                                                                                   currentMonthPrice: currentMonthPrice) }
    self.exchangeOptionsItemViewModels.forEach { $0.delegate = self }
  }
}

// MARK: - ExchangeOptionsItemViewModelDelegate

extension ExchangeOptionsViewModel: ExchangeOptionsItemViewModelDelegate {
  func exchangeOptionsItemViewModel(_ viewModel: ExchangeOptionsItemViewModel, didSelectModel model: ModelInfo) {
    delegate?.exchangeOptionsViewModel(self, didSelectModel: model)
  }
}

// MARK: - CommonTableCellViewModel

extension ExchangeOptionsViewModel: CommonTableCellViewModel {
  var tableCellIdentifier: String {
    return ExchangeOptionsCell.reuseIdentifier
  }
}
