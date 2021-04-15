//
//  ProductPropertyPickerItemViewModel.swift
//  ForwardLeasing
//

import Foundation

protocol ProductPropertyPickerItemViewModelDelegate: class {
  func productPropertyPickerItemViewModel(_ viewModel: ProductPropertyPickerItemViewModel,
                                          didSetSelectedStateTo isSelected: Bool)
}

class ProductPropertyPickerItemViewModel: ProductPropertyPickerItemViewModelProtocol {
  weak var delegate: ProductPropertyPickerItemViewModelDelegate?
  
  var onDidUpdate: (() -> Void)?
  let title: String?
  private(set) var isSelected: Bool
  private(set) var isEnabled: Bool
  
  init(title: String?, isSelected: Bool = false, isEnabled: Bool = true) {
    self.title = title
    self.isSelected = isSelected
    self.isEnabled = isEnabled
  }
  
  func toggleSelectionStateByTap() {
    setSelected(to: true) // cannot deselect by tapping
  }

  func setSelected(to isSelected: Bool) {
    self.isSelected = isSelected
    onDidUpdate?()
    delegate?.productPropertyPickerItemViewModel(self, didSetSelectedStateTo: isSelected)
  }
  
  func setEnabled(to isEnabled: Bool) {
    self.isEnabled = isEnabled
    onDidUpdate?()
  }
}
