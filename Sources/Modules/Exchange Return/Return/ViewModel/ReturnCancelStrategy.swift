//
//  ReturnCancelStrategy.swift
//  ForwardLeasing
//

import Foundation
import PromiseKit

class ReturnCancelStrategy: ExchangeReturnCancelStrategy {
  private let contractService: ContractNetworkProtocol

  init(contractService: ContractNetworkProtocol) {
    self.contractService = contractService
  }

  func cancel(with id: String) -> Promise<EmptyResponse> {
    contractService.cancelReturn(applicationID: id)
  }
}
