//
//  ExchangeViewModelInput.swift
//  ForwardLeasing
//

import Foundation

struct ExchangeViewModelInput: ExchangeReturnViewModelInput {
  let screenTitle = R.string.exchangeInfo.screenTitle()
  let needsContractInfo = true
  let priceViewModelTitles: ExchangeReturnPriceTitles = ExchangePriceTitles()
  let buttonsTitles: ExchangeReturnButtonsTitles = ExchangeButtonsTitles()
  let barcodeTitles: ExchangeReturnBarcodeTitles = ExchangeBarcodeTitles()
  let selectStoreTitle = R.string.exchangeInfo.selectStoreTitle()
  let completeTitle = R.string.exchangeInfo.completeTitle()
  let stateStrategy: ExchangeReturnViewModelStateStrategy = ExchangeViewModelStateStrategy()
  let paymentInfoStrategy: ExchangeReturnPaymentInfoStrategy = ExchangePaymentInfoStrategy()
  let cancelStrategy: ExchangeReturnCancelStrategy
  let applicationID: String
}
