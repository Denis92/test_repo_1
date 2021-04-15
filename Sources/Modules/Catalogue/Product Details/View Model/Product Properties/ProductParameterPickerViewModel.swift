//
//  ProductParameterPickerViewModel.swift
//  ForwardLeasing
//

import UIKit

protocol ProductParameterPickerViewModelDelegate: class {
  func productParameterPickerViewModel(_ viewModel: ProductParameterPickerViewModel,
                                       didSelectParameter parameter: ProductParameter,
                                       withIndex index: Int)
}

class ProductParameterPickerViewModel: ProductPropertyPickerViewModelProtocol, ProductDetailsItemViewModel {
  typealias View = ProductPropertyPickerView
  // MARK: - Properties
  
  weak var delegate: ProductParameterPickerViewModelDelegate?
  
  let itemViewModels: [ProductPropertyPickerItemViewModel]
  let title: String?
  let type: ProductDetailsItemType = .propertyPicker
  let customSpacing: CGFloat? = 32

  private let productParameters: [ProductParameter]
  
  // MARK: - Init
  
  init(title: String?, parameters: [ProductParameter], selectedIndex: Int = 0) {
    self.title = title
    self.productParameters = parameters
    self.itemViewModels = parameters.compactMap { ProductPropertyPickerItemViewModel(title: $0.value) }
    self.itemViewModels.forEach { $0.delegate = self }
    self.itemViewModels.element(at: selectedIndex)?.setSelected(to: true)
  }
}

// MARK: - ProductPropertyPickerItemViewModelDelegate

extension ProductParameterPickerViewModel: ProductPropertyPickerItemViewModelDelegate {
  func productPropertyPickerItemViewModel(_ viewModel: ProductPropertyPickerItemViewModel,
                                          didSetSelectedStateTo isSelected: Bool) {
    guard isSelected else { return }
    itemViewModels.forEach { itemViewModel in
      if itemViewModel !== viewModel {
        itemViewModel.setSelected(to: false)
      }
    }
    
    if let index = itemViewModels.firstIndex(where: { $0 === viewModel }),
       let parameter = productParameters.element(at: index) {
      delegate?.productParameterPickerViewModel(self, didSelectParameter: parameter, withIndex: index)
    }
  }
}
