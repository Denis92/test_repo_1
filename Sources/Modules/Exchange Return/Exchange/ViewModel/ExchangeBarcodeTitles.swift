//
//  ExchangeBarcodeTitles.swift
//  ForwardLeasing
//

import Foundation

struct ExchangeBarcodeTitles: ExchangeReturnBarcodeTitles {
  func text(with exchangeInfoState: ExchangeReturnState, titleType: ExchangeReturnBarcodeTitleType) -> String {
    switch (exchangeInfoState, titleType) {
    case (.complete, .title):
      return R.string.exchangeInfo.barcodeCompleteTitle()
    case (_, .title):
      return R.string.exchangeInfo.barcodeTitle()
    case (.complete, .header):
      return ""
    case (_, .header):
      return R.string.exchangeInfo.barcodeInfoTitle()
    case (.complete, .description):
      return R.string.exchangeInfo.barcodeCompleteInfoDesctiption()
    case (_, .description):
      return R.string.exchangeInfo.barcodeInfoDesctiption()
    }
  }
}
