//
//  ExchangePriceTitles.swift
//  ForwardLeasing
//

import Foundation

struct ExchangePriceTitles: ExchangeReturnPriceTitles {
  let title: String  = R.string.exchangeInfo.priceTitle()
  let earlyPriceTitle: String = R.string.exchangeInfo.earlyExchangePriceTitle()
  let deviceStatePriceTitle: String = R.string.exchangeInfo.deviceStatePriceTitle()
  let totalPriceTitle = R.string.exchangeInfo.totalPriceTitle()
  let unknownTotalPriceTitle = R.string.exchangeInfo.unknownTotalPriceTitle()
}
