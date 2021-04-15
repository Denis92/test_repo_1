//
//  ExchangeReturnPriceTitles.swift
//  ForwardLeasing
//

import Foundation

protocol ExchangeReturnPriceTitles {
  var title: String { get }
  var earlyPriceTitle: String { get }
  var deviceStatePriceTitle: String { get }
  var totalPriceTitle: String { get }
  var unknownTotalPriceTitle: String { get }
}
