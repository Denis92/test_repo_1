//
//  ExchangeReturnCancelStrategy.swift
//  ForwardLeasing
//

import Foundation
import PromiseKit

protocol ExchangeReturnCancelStrategy {
  func cancel(with id: String) -> Promise<EmptyResponse>
}
