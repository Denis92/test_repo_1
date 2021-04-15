//
//  ReturnPriceTitles.swift
//  ForwardLeasing
//

import Foundation

struct ReturnPriceTitles: ExchangeReturnPriceTitles {
  let title: String = R.string.returnInfo.priceTitle()
  let earlyPriceTitle: String = R.string.returnInfo.earlyExchangePriceTitle()
  let deviceStatePriceTitle: String = R.string.returnInfo.deviceStatePriceTitle()
  let totalPriceTitle = R.string.returnInfo.totalPriceTitle()
  let unknownTotalPriceTitle = R.string.returnInfo.unknownTotalPriceTitle()
}
