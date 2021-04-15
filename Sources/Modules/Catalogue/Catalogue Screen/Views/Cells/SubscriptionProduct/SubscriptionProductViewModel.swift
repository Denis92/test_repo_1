//
//  SubscriptionProductViewModel.swift
//  ForwardLeasing
//

import UIKit

class SubscriptionProductViewModel: CommonTableCellViewModel, SubscriprionProductViewModelProtocol {
  private typealias Cell = CommonContainerTableViewCell<SubscriptionProductView>
  
  var tableCellIdentifier: String {
    return Cell.reuseIdentifier
  }
  
  var backgroundColor: UIColor? {
    guard let hexColor = selectedItem?.hexColor else { return nil }
    return UIColor(hexString: hexColor)
  }
  
  var price: String? {
    return selectedItem?.price
  }
  
  var imageURL: URL? {
    guard let imageURL = selectedItem?.imageURLs.first else {
      return nil
    }
    return imageURL.toURL()
  }

  var durationViewModels: [ProductPropertyPickerItemViewModelProtocol] {
    return subscriptionDurationViewModels
  }

  var onDidUpdateSelectedItem: (() -> Void)?
  
  let name: String?
  let onDidTapBuy: ((SubscriptionProductItem) -> Void)?
  
  private let items: [SubscriptionProductItem]
  private var selectedItem: SubscriptionProductItem?
  private var subscriptionDurationViewModels: [SubscriptionProductDurationViewModel] = []
  
  init(from subscriptionProduct: SubscriptionProduct,
       onDidTapBuy: ((SubscriptionProductItem) -> Void)?) {
    items = subscriptionProduct.items.sorted { $0.sortOrder < $1.sortOrder }
    name = subscriptionProduct.name
    selectedItem = items.first
    self.onDidTapBuy = onDidTapBuy
    subscriptionDurationViewModels = items.map {
      let viewModel = SubscriptionProductDurationViewModel(title: R.string.catalogue.subscriptionProductMonths($0.months),
                                                           isSelected: $0 == selectedItem)
      viewModel.delegate = self
      return viewModel
    }
  }
  
  func buy() {
    guard let selectedItem = selectedItem else { return }
    onDidTapBuy?(selectedItem)
  }
}

// MARK: - SubscriptionProductDurationViewModelDelega

extension SubscriptionProductViewModel: SubscriptionProductDurationViewModelDelegate {
  func subscriptionProductDurationViewModel(_ viewModel: SubscriptionProductDurationViewModel,
                                            didSetSelectedStateTo isSelected: Bool) {
    guard isSelected else { return }
    subscriptionDurationViewModels.filter { !($0 === viewModel) }.forEach { $0.setSelected(to: false) }

    if let index = subscriptionDurationViewModels.firstIndex(where: { $0 === viewModel }),
       let item = items.element(at: index) {
      selectedItem = item
    }

    onDidUpdateSelectedItem?()
  }
}
