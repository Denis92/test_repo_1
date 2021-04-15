//
//  SubscriptionContractHeaderViewModel.swift
//  ForwardLeasing
//

import Foundation
import UIKit.UIColor

struct SubscriptionContractHeaderViewModel: SubscriptionContractHeaderViewModelProtocol {
  var imageURL: URL? {
    return subscription.imageURLString.toURL()
  }

  var backgroundColor: UIColor {
    return .base2
  }

  private let subscription: BoughtSubscription

  init(subscription: BoughtSubscription) {
    self.subscription = subscription
  }
}
