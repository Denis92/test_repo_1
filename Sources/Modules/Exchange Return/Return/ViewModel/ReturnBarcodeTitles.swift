//
//  ReturnBarcodeTitles.swift
//  ForwardLeasing
//

import Foundation

struct ReturnBarcodeTitles: ExchangeReturnBarcodeTitles {
  func text(with exchangeInfoState: ExchangeReturnState, titleType: ExchangeReturnBarcodeTitleType) -> String {
    switch (exchangeInfoState, titleType) {
    case (.complete, .title):
      return R.string.returnInfo.barcodeCompleteTitle()
    case (_, .title):
      return R.string.returnInfo.barcodeTitle()
    case (.complete, .header):
      return ""
    case (_, .header):
      return R.string.returnInfo.barcodeInfoTitle()
    case (.complete, .description):
      return R.string.returnInfo.barcodeCompleteInfoDesctiption()
    case (_, .description):
      return R.string.returnInfo.barcodeInfoDesctiption()
    }
  }
}
