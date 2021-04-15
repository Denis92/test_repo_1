//
//  ExchangeCancelStrategy.swift
//  ForwardLeasing
//

import Foundation
import PromiseKit

class ExchangeCancelStrategy: ExchangeReturnCancelStrategy {
  private let contractService: ContractNetworkProtocol

  init(contractService: ContractNetworkProtocol) {
    self.contractService = contractService
  }

  func cancel(with id: String) -> Promise<EmptyResponse> {
    contractService.cancelContract(applicationID: id)
  }
}
