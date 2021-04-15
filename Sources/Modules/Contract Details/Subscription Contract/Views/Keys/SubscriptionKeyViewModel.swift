//
//  SubscriptionKeyViewModel.swift
//  ForwardLeasing
//

import Foundation
import UIKit.UIPasteboard

protocol SubscriptionKeyViewModelDelegate: class {
  func subscriptionKeyViewModelDidCopyKey(_ viewModel: SubscriptionKeyViewModel)
}

class SubscriptionKeyViewModel: SubscriptionKeyViewModelProtocol {
  let key: String
  
  weak var delegate: SubscriptionKeyViewModelDelegate?

  init(key: String) {
    self.key = key
  }

  func copyKey() {
    UIPasteboard.general.string = key
    delegate?.subscriptionKeyViewModelDidCopyKey(self)
  }
}
