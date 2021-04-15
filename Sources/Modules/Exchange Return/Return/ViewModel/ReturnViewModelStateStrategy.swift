//
//  ReturnViewModelStateStrategy.swift
//  ForwardLeasing
//

import Foundation

struct ReturnViewModelStateStrategy: ExchangeReturnViewModelStateStrategy{
  func getState(with contract: LeasingEntity,
                lastDiagnosticSessionID: String?) -> ExchangeReturnState {
    if contract.contractActionInfo?.upgradeReturnSumPaid == true {
      return .complete
    }

    if contract.status == .returnCreated,
       !(contract.contractActionInfo?.upgradeReturnPaymentSum?.isZero ?? true) {
      return.payForExhcange
    }

    if contract.status == .returnCreated,
       contract.contractActionInfo?.diagnosticType == .forward,
       contract.contractActionInfo?.checkSessionID != nil,
       lastDiagnosticSessionID != contract.contractActionInfo?.checkSessionID {
      return .passDiagnostics
    }

    if contract.status == .returnCreated,
       contract.contractActionInfo?.storePoint == nil {
      return .selectStore
    }
    return .awatingDiagnostics
  }
}
