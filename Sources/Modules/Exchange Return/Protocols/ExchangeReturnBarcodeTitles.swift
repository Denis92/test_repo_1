//
//  ExchangeReturnBarcodeTitles.swift
//  ForwardLeasing
//

import Foundation

enum ExchangeReturnBarcodeTitleType {
  case title
  case header
  case description
}

protocol ExchangeReturnBarcodeTitles {
  func title(with exchangeInfoState: ExchangeReturnState) -> String
  func header(with exchangeInfoState: ExchangeReturnState) -> String
  func description(with exchangeInfoState: ExchangeReturnState) -> String
  func text(with exchangeInfoState: ExchangeReturnState, titleType: ExchangeReturnBarcodeTitleType) -> String
}

extension ExchangeReturnBarcodeTitles {
  func title(with exchangeInfoState: ExchangeReturnState) -> String {
    return text(with: exchangeInfoState, titleType: .title)
  }
  func header(with exchangeInfoState: ExchangeReturnState) -> String {
    return text(with: exchangeInfoState, titleType: .header)
  }
  func description(with exchangeInfoState: ExchangeReturnState) -> String {
    return text(with: exchangeInfoState, titleType: .description)
  }
}
