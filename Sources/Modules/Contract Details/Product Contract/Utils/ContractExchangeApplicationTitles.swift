//
//  ContractExchangeApplicationTitles.swift
//  ForwardLeasing
//

import Foundation

struct ContractExchangeApplicationTitles: ContractAdditionalApplicationTitles {
  func primaryButtonTitle(with state: ContractAdditionalApplicationState) -> String? {
    switch state {
    case .new, .freeExchange, .awaitingExchange, .paid:
      return R.string.contractDetails.continueButtonTitle()
    case .awaitingDiagnostics:
      return R.string.contractDetails.diagnosticsButtonTitle()
    case .comission:
      return R.string.contractDetails.comissionButtonTitle()
    case .onDiagnostics:
      return nil
    }
  }

  func statusTitle(with state: ContractAdditionalApplicationState) -> String? {
    switch state {
    case .new, .awaitingDiagnostics, .onDiagnostics:
      return nil
    case .comission:
      return R.string.contractDetails.exchangeStatusComission()
    case .freeExchange, .awaitingExchange:
      return R.string.contractDetails.exchangeStatusFreeExchange()
    case .paid:
      return R.string.contractDetails.exchangeStatusPaid()
    }
  }
}
