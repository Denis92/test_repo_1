//
//  ProductColorPickerItemViewModel.swift
//  ForwardLeasing
//

import UIKit

protocol ProductColorPickerItemViewModelDelegate: class {
  func productColorPickerItemViewModel(_ viewModel: ProductColorPickerItemViewModel,
                                       didSetSelectedState isSelected: Bool,
                                       allowsDeselection: Bool)
}

class ProductColorPickerItemViewModel {
  weak var delegate: ProductColorPickerItemViewModelDelegate?
  
  var onDidUpdate: (() -> Void)?
  
  let color: UIColor
  private(set) var isSelected: Bool
  private let allowsDeselection: Bool
  
  init(color: UIColor, allowsDeselection: Bool = false, isSelected: Bool = false) {
    self.color = color
    self.isSelected = isSelected
    self.allowsDeselection = allowsDeselection
  }
  
  func setSelected(to isSelected: Bool) {
    self.isSelected = isSelected
    onDidUpdate?()
  }
  
  func didTapView() {
    if !isSelected {
      setSelected(to: true)
    } else if allowsDeselection {
      setSelected(to: false)
    } else {
      return
    }
    delegate?.productColorPickerItemViewModel(self, didSetSelectedState: isSelected,
                                              allowsDeselection: allowsDeselection)
  }
}
