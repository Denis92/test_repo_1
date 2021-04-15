//
//  ExchangeReturnPriceViewModel.swift
//  ForwardLeasing
//

import Foundation

struct ExchangeReturnPriceViewModel {
  var earlyExchangePrice: String {
    return earlyExchangePayment?.priceString() ?? R.string.exchangeInfo.priceUnknown()
  }
  
  var deviceStatePrice: String {
    return deviceStatePayment?.priceString() ?? R.string.exchangeInfo.priceUnknown()
  }
  
  var totalPrice: String {
    return totalPayment?.priceString() ?? R.string.exchangeInfo.priceUnknown()
  }
  
  var hasEarlyExchangePayment: Bool {
    return !(earlyExchangePayment?.isZero ?? true)
  }
  
  var hasTotalPrice: Bool {
    return totalPayment != nil
  }
  
  let priceViewModelTitles: ExchangeReturnPriceTitles

  private let earlyExchangePayment: Decimal?
  private var totalPayment: Decimal?
  private var deviceStatePayment: Decimal? {
    guard let earlyExchangePayment = earlyExchangePayment,
          let totalPayment = totalPayment else { return nil }
    return totalPayment - earlyExchangePayment
  }
  
  init(earlyExchangePayment: Decimal?,
       totalPayment: Decimal?,
       priceViewModelTitles: ExchangeReturnPriceTitles) {
    self.earlyExchangePayment = earlyExchangePayment
    self.totalPayment = totalPayment
    self.priceViewModelTitles = priceViewModelTitles
  }
}

// MARK: - CommonTableCellViewModel

extension ExchangeReturnPriceViewModel: CommonTableCellViewModel {
  var tableCellIdentifier: String {
    return ExchangeReturnPriceCell.reuseIdentifier
  }
}
