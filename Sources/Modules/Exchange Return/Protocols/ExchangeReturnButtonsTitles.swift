//
//  ExchangeReturnButtonsTitles.swift
//  ForwardLeasing
//

import Foundation

protocol ExchangeReturnButtonsTitles {
  var cancelButtonTitle: String? { get }
  func primaryButtonTitle(exchangeInfoState: ExchangeReturnState) -> String?
}
