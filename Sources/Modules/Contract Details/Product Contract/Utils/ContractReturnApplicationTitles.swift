//
//  ContractReturnApplicationTitles.swift
//  ForwardLeasing
//

import Foundation

struct ContractReturnApplicationTitles: ContractAdditionalApplicationTitles {
  private let contract: LeasingEntity
  
  init(contract: LeasingEntity) {
    self.contract = contract
  }
  
  func primaryButtonTitle(with state: ContractAdditionalApplicationState) -> String? {
    switch state {
    case .new, .freeExchange, .awaitingExchange, .paid:
      return R.string.contractDetails.continueButtonTitle()
    case .awaitingDiagnostics:
      return R.string.contractDetails.diagnosticsButtonTitle()
    case .comission:
      return R.string.contractDetails.paymentButtonTitle()
    case .onDiagnostics:
      return nil
    }
  }

  func statusTitle(with state: ContractAdditionalApplicationState) -> String? {
    switch state {
    case .new:
      return nil
    case .awaitingDiagnostics, .onDiagnostics:
      return nil
    case .comission, .freeExchange:
      return R.string.contractDetails.returnStatusDiagnosticsComplete()
    case .paid, .awaitingExchange:
      return R.string.contractDetails.returnStatusPaid()
    }
  }
}
