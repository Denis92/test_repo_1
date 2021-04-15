//
//  ReturnButtonsTitles.swift
//  ForwardLeasing
//

import Foundation

struct ReturnButtonsTitles: ExchangeReturnButtonsTitles {
  let cancelButtonTitle: String? = R.string.returnInfo.cancelContractButtonTitle()

  func primaryButtonTitle(exchangeInfoState: ExchangeReturnState) -> String? {
    switch exchangeInfoState {
    case .selectStore:
      return R.string.returnInfo.primaryButtonReturnToContractTitle()
    case .passDiagnostics:
      return R.string.returnInfo.primaryButtonPassDiagnosticsTitle()
    case .payForExhcange:
      return R.string.returnInfo.primaryButtonMakePaymentTitle()
    case .freeExchange:
      return R.string.common.continue()
    case .awatingDiagnostics:
      return nil
    case .complete:
      return R.string.common.done()
    }
  }
}
