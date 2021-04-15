//
//  SubscriptionKeyListViewModel.swift
//  ForwardLeasing
//

import Foundation

protocol SubscriptionKeyListViewModelDelegate: class {
  func subscriptionKeyListViewModelDidCopyKey(_ viewModel: SubscriptionKeyListViewModel)
  func subscriptionKeyListViewModel(_ viewModel: SubscriptionKeyListViewModel, didRequestShareKeys keys: [String])
}

class SubscriptionKeyListViewModel: SubscriptionKeyListViewModelProtocol {
  let keyViewModels: [SubscriptionKeyViewModelProtocol]
  
  weak var delegate: SubscriptionKeyListViewModelDelegate?
  
  private let keys: [String]
  
  init(keys: [String]) {
    self.keys = keys
    let keyViewModels = keys.map { SubscriptionKeyViewModel(key: $0) }
    self.keyViewModels = keyViewModels
    keyViewModels.forEach {
      $0.delegate = self
    }
  }
  
  func shareKeys() {
    delegate?.subscriptionKeyListViewModel(self, didRequestShareKeys: keys)
  }
}

// MARK: - SubscriptionKeyViewModelDelegate
extension SubscriptionKeyListViewModel: SubscriptionKeyViewModelDelegate {
  func subscriptionKeyViewModelDidCopyKey(_ viewModel: SubscriptionKeyViewModel) {
    delegate?.subscriptionKeyListViewModelDidCopyKey(self)
  }
}
