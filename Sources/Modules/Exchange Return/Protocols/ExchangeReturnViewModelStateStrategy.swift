//
//  ExchangeReturnViewModelStateStrategy.swift
//  ForwardLeasing
//

import Foundation

protocol ExchangeReturnViewModelStateStrategy {
  func getState(with contract: LeasingEntity,
                lastDiagnosticSessionID: String?) -> ExchangeReturnState
}
