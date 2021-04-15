//
//  SubscriptionProductDurationViewModel.swift
//  ForwardLeasing
//

import CoreGraphics

protocol SubscriptionProductDurationViewModelDelegate: class {
  func subscriptionProductDurationViewModel(_ viewModel: SubscriptionProductDurationViewModel,
                                            didSetSelectedStateTo isSelected: Bool)
}

class SubscriptionProductDurationViewModel: ProductPropertyPickerItemViewModelProtocol {
  weak var delegate: SubscriptionProductDurationViewModelDelegate?

  var onDidUpdate: (() -> Void)?

  let title: String?
  let isEnabled: Bool = true

  private (set) var isSelected: Bool

  init(title: String?, isSelected: Bool = false) {
    self.title = title
    self.isSelected = isSelected
  }

  func toggleSelectionStateByTap() {
    setSelected(to: true) // cannot deselect by tapping
  }

  func setSelected(to isSelected: Bool) {
    self.isSelected = isSelected
    onDidUpdate?()
    delegate?.subscriptionProductDurationViewModel(self, didSetSelectedStateTo: isSelected)
  }
}
