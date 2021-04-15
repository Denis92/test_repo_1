//
//  ExchangeViewModelStateStrategy.swift
//  ForwardLeasing
//

import Foundation

struct ExchangeViewModelStateStrategy: ExchangeReturnViewModelStateStrategy{
  func getState(with contract: LeasingEntity,
                lastDiagnosticSessionID: String?) -> ExchangeReturnState {
    if contract.contractActionInfo?.upgradeReturnSumPaid == true {
      return .complete
    }

    if contract.status == .signed,
       !(contract.contractActionInfo?.upgradeReturnPaymentSum?.isZero ?? true) {
      return.payForExhcange
    }

    if contract.status == .signed,
       contract.contractActionInfo?.diagnosticType == .forward,
       contract.contractActionInfo?.checkSessionID != nil,
       lastDiagnosticSessionID != contract.contractActionInfo?.checkSessionID {
      return .passDiagnostics
    }

    if contract.status == .signed,
       contract.contractActionInfo?.storePoint == nil {
      return .selectStore
    }
    return .awatingDiagnostics
  }
}
