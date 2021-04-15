//
//  ProductDeliveryTypeViewModel.swift
//  ForwardLeasing
//

import UIKit

protocol ProductDeliveryTypeViewModelDelegate: class {
  func productDeliveryTypeViewModel(_ viewModel: ProductDeliveryTypeViewModel,
                                    didSelectDeliveryOption option: ProductDeliveryOption,
                                    withIndex index: Int)
}

class ProductDeliveryTypeViewModel: ProductPropertyPickerViewModelProtocol, ProductDetailsItemViewModel {
  // MARK: - Properties
  
  weak var delegate: ProductDeliveryTypeViewModelDelegate?
  
  var title: String? {
    return R.string.productDetails.deliveryPickerTitle()
  }
  
  let itemViewModels: [ProductPropertyPickerItemViewModel]
  let type: ProductDetailsItemType = .propertyPicker
  let customSpacing: CGFloat? = 44

  private let deliveryOptions: [ProductDeliveryOption]
  
  // MARK: - Init
  
  init(deliveryOptions: [ProductDeliveryOption]) {
    self.deliveryOptions = deliveryOptions
    itemViewModels = deliveryOptions.map { ProductPropertyPickerItemViewModel(title: $0.name) }
    itemViewModels.forEach { $0.delegate = self }
    itemViewModels.element(at: deliveryOptions.firstIndex { $0.isDefault } ?? 0)?.setSelected(to: true)
  }
}

// MARK: - ProductPropertyPickerItemViewModelDelegate

extension ProductDeliveryTypeViewModel: ProductPropertyPickerItemViewModelDelegate {
  func productPropertyPickerItemViewModel(_ viewModel: ProductPropertyPickerItemViewModel,
                                          didSetSelectedStateTo isSelected: Bool) {
    guard isSelected else { return }
    itemViewModels.forEach { itemViewModel in
      if itemViewModel !== viewModel {
        itemViewModel.setSelected(to: false)
      }
    }
    
    if let index = itemViewModels.firstIndex(where: { $0 === viewModel }),
       let option = deliveryOptions.element(at: index) {
      delegate?.productDeliveryTypeViewModel(self, didSelectDeliveryOption: option, withIndex: index)
    }
  }
}
