//
//  ReturnViewModelInput.swift
//  ForwardLeasing
//

import Foundation

struct ReturnViewModelInput: ExchangeReturnViewModelInput {
  let screenTitle = R.string.returnInfo.screenTitle()
  let needsContractInfo = false
  let priceViewModelTitles: ExchangeReturnPriceTitles = ReturnPriceTitles()
  let buttonsTitles: ExchangeReturnButtonsTitles = ReturnButtonsTitles()
  let barcodeTitles: ExchangeReturnBarcodeTitles = ReturnBarcodeTitles()
  let selectStoreTitle = R.string.returnInfo.selectStoreTitle()
  let completeTitle = R.string.returnInfo.completeTitle()
  let stateStrategy: ExchangeReturnViewModelStateStrategy = ReturnViewModelStateStrategy()
  let paymentInfoStrategy: ExchangeReturnPaymentInfoStrategy = ReturnPaymentInfoStrategy()
  let cancelStrategy: ExchangeReturnCancelStrategy
  let applicationID: String
}
