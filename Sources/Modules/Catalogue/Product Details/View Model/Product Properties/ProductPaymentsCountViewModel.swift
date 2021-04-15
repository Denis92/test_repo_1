//
//  ProductPaymentsCountViewModel.swift
//  ForwardLeasing
//

import UIKit

protocol ProductPaymentsCountViewModelDelegate: class {
  func productParameterPickerViewModel(_ viewModel: ProductPaymentsCountViewModel,
                                       didSelectLeasingOption option: LeasingProductInfo,
                                       withIndex index: Int)
}

class ProductPaymentsCountViewModel: ProductPropertyPickerViewModelProtocol, ProductDetailsItemViewModel {
  // MARK: - Properties
  
  weak var delegate: ProductPaymentsCountViewModelDelegate?
  
  var title: String? {
    return R.string.productDetails.paymentsCountTitle()
  }

  let type: ProductDetailsItemType = .propertyPicker
  let customSpacing: CGFloat? = 32

  private(set) var itemViewModels: [ProductPropertyPickerItemViewModel]
  private var leasingOptions: [LeasingProductInfo]
  
  // MARK: - Init
  
  init(leasingOptions: [LeasingProductInfo]) {
    self.leasingOptions = leasingOptions
    self.itemViewModels = leasingOptions.compactMap { ProductPropertyPickerItemViewModel(title: "\($0.paymentsCount)") }
    self.itemViewModels.forEach { $0.delegate = self }
    self.itemViewModels.first?.setSelected(to: true)
  }
}

// MARK: - ProductPropertyPickerItemViewModelDelegate

extension ProductPaymentsCountViewModel: ProductPropertyPickerItemViewModelDelegate {
  func productPropertyPickerItemViewModel(_ viewModel: ProductPropertyPickerItemViewModel,
                                          didSetSelectedStateTo isSelected: Bool) {
    guard isSelected else { return }
    itemViewModels.forEach { itemViewModel in
      if itemViewModel !== viewModel {
        itemViewModel.setSelected(to: false)
      }
    }
    
    if let index = itemViewModels.firstIndex(where: { $0 === viewModel }),
       let option = leasingOptions.element(at: index) {
      delegate?.productParameterPickerViewModel(self, didSelectLeasingOption: option, withIndex: index)
    }
  }
}
