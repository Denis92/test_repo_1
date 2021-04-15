//
//  SelectDeliveryError.swift
//  ForwardLeasing
//

import Foundation

enum SelectDeliveryError: LocalizedError {
  case goodUnavailable, productDelivery
  
  var errorDescription: String? {
    switch self {
    case .productDelivery:
      return R.string.deliveryProduct.selectDeliveryRegularError()
    case .goodUnavailable:
      return R.string.deliveryProduct.selectedGoodIsUnavailableTitle()
    }
  }
}
