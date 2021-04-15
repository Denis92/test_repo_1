//
//  ExchangeButtonsTitles.swift
//  ForwardLeasing
//

import Foundation

struct ExchangeButtonsTitles: ExchangeReturnButtonsTitles {
  let cancelButtonTitle: String? = R.string.exchangeInfo.cancelContractButtonTitle()

  func primaryButtonTitle(exchangeInfoState: ExchangeReturnState) -> String? {
    switch exchangeInfoState {
    case .selectStore:
      return R.string.exchangeInfo.primaryButtonReturnToContractTitle()
    case .passDiagnostics:
      return R.string.exchangeInfo.primaryButtonPassDiagnosticsTitle()
    case .payForExhcange:
      return R.string.exchangeInfo.primaryButtonMakePaymentTitle()
    case .freeExchange:
      return R.string.common.continue()
    case .awatingDiagnostics:
      return nil
    case .complete:
      return R.string.common.done()
    }
  }
}
