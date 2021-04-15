//
//  DeeplinkType.swift
//  ForwardLeasing
//

import Foundation

enum DeeplinkType {
  case productDetails(goodCode: String)
  case category(categoryCode: String)
  case profile
  case contractDetails(contractID: String)
}
