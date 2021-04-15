//
//  ContractDeliveryStatusAsset.swift
//  ForwardLeasing
//

import Foundation

struct ContractDeliveryStatusAsset {
  static func title(for deliveryStatus: DeliveryStatus) -> String {
    switch deliveryStatus {
    case .new:
      return R.string.contractDetails.deliveryCreatedTitle()
    case .delivering:
      return R.string.contractDetails.deliveryDeliveringTitle()
    case .delivered:
      return R.string.contractDetails.deliveryCompletedTitle()
    case .lost:
      return R.string.contractDetails.deliveryLostTitle()
    case .shipped:
      return R.string.contractDetails.deliveryShippedTitle()
    case .error:
      return R.string.contractDetails.deliveryErrorTitle()
    default:
      return ""
    }
  }
}
