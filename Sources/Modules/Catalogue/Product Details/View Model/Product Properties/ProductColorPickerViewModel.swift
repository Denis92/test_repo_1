//
//  ProductColorPickerViewModel.swift
//  ForwardLeasing
//

import UIKit

protocol ProductColorPickerViewModelDelegate: class {
  func productColorPickerViewModel(didSelectColor color: ProductColor, withIndex index: Int)
}

class ProductColorPickerViewModel: ProductDetailsItemViewModel {
  // MARK: - Properties
  
  weak var delegate: ProductColorPickerViewModelDelegate?
  
  var title: String {
    return R.string.productDetails.colorPickerTitle(productColors.element(at: selectedColorIndex)?
                                                      .colorName.lowercased() ?? "")
  }
  
  let itemViewModels: [ProductColorPickerItemViewModel]
  let type: ProductDetailsItemType = .colorPicker
  let customSpacing: CGFloat? = 32

  private(set) var selectedColorIndex: Int
  
  private let productColors: [ProductColor]
  
  // MARK: - Init
  
  init(colors: [ProductColor], selectedColorIndex: Int = 0) {
    self.productColors = colors
    self.itemViewModels = colors.compactMap { ProductColorPickerItemViewModel(color: UIColor(hexString: $0.colorCode)) }
    self.selectedColorIndex = selectedColorIndex
    self.itemViewModels.forEach { $0.delegate = self }
    self.itemViewModels.first?.setSelected(to: true)
  }
}

// MARK: - ProductColorPickerItemViewModelDelegate

extension ProductColorPickerViewModel: ProductColorPickerItemViewModelDelegate {
  func productColorPickerItemViewModel(_ viewModel: ProductColorPickerItemViewModel,
                                       didSetSelectedState isSelected: Bool, allowsDeselection: Bool) {
    guard isSelected else { return }
    
    itemViewModels.forEach { itemViewModel in
      if itemViewModel !== viewModel {
        itemViewModel.setSelected(to: false)
      }
    }
    
    if let index = itemViewModels.firstIndex(where: { $0 === viewModel }),
       let color = productColors.element(at: index) {
      delegate?.productColorPickerViewModel(didSelectColor: color, withIndex: index)
      self.selectedColorIndex = index
    }
  }
}
