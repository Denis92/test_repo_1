//
//  ProductProgramPickerViewModel.swift
//  ForwardLeasing
//

import UIKit

protocol ProductProgramPickerViewModelDelegate: class {
  func productProgramPickerViewModel(_ viewModel: ProductProgramPickerViewModel,
                                     didSetStateOf service: ProductAdditionalService,
                                     withIndex index: Int, isSelected: Bool)
}

class ProductProgramPickerViewModel: ProductDetailsItemViewModel {
  weak var delegate: ProductProgramPickerViewModelDelegate?
  
  var title: String? {
    return R.string.productDetails.programPickerTitle()
  }
  
  let itemViewModels: [ProductProgramPickerItemViewModel]
  let type: ProductDetailsItemType = .programPicker
  let customSpacing: CGFloat? = 32


  init(services: [ProductAdditionalService]) {
    itemViewModels = services.map { return ProductProgramPickerItemViewModel(service: $0) }
    itemViewModels.forEach { $0.delegate = self }
  }
}

// MARK: - ProductProgramPickerItemViewModelDelegate

extension ProductProgramPickerViewModel: ProductProgramPickerItemViewModelDelegate {
  func productProgramPickerItemViewModel(_ viewModel: ProductProgramPickerItemViewModel,
                                         didSetStateOf service: ProductAdditionalService,
                                         isSelected: Bool) {
    guard let index = itemViewModels.firstIndex(where: { $0 === viewModel }) else { return }
    delegate?.productProgramPickerViewModel(self, didSetStateOf: service, withIndex: index,
                                            isSelected: isSelected)
  }
}
