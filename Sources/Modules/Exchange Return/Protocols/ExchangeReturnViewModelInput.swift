//
//  ExchangeReturnViewModelInput.swift
//  ForwardLeasing
//

import Foundation

protocol ExchangeReturnViewModelInput {
  var cancelStrategy: ExchangeReturnCancelStrategy { get }
  var paymentInfoStrategy: ExchangeReturnPaymentInfoStrategy { get }
  var stateStrategy: ExchangeReturnViewModelStateStrategy { get }
  var priceViewModelTitles: ExchangeReturnPriceTitles { get }
  var buttonsTitles: ExchangeReturnButtonsTitles { get }
  var barcodeTitles: ExchangeReturnBarcodeTitles { get }
  var selectStoreTitle: String { get }
  var completeTitle: String { get }
  var screenTitle: String { get }
  var applicationID: String { get }
  var needsContractInfo: Bool { get }
}
