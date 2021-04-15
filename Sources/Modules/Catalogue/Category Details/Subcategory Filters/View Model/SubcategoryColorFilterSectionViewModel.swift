//
//  SubcategoryColorFilterSectionViewModel.swift
//  ForwardLeasing
//

import UIKit

protocol SubcategoryColorFilterSectionViewModelDelegate: class {
  func subcategoryColorFilterSectionViewModel(_ viewModel: SubcategoryColorFilterSectionViewModel,
                                              didUpdateSelectedColors colors: [ProductColor])
}

class SubcategoryColorFilterSectionViewModel {
  // MARK: - Properties
  
  weak var delegate: SubcategoryColorFilterSectionViewModelDelegate?
  
  let title: String?
  let itemViewModels: [ProductColorPickerItemViewModel]
  
  private let productColors: [ProductColor]
  private var selectedColors = Set<ProductColor>()
  
  // MARK: - Init
  
  init(colorFilter: ColorFilter) {
    self.title = colorFilter.title
    self.productColors = colorFilter.options.map { $0.color }
    self.itemViewModels = colorFilter.options.compactMap { option in
      return ProductColorPickerItemViewModel(color: UIColor(hexString: option.color.colorCode),
                                             allowsDeselection: true, isSelected: option.isSelected)
    }
    self.itemViewModels.forEach { $0.delegate = self }
  }
  
  func reset() {
    selectedColors.removeAll()
    itemViewModels.forEach { $0.setSelected(to: false) }
  }
}

// MARK: - ProductColorPickerItemViewModelDelegate

extension SubcategoryColorFilterSectionViewModel: ProductColorPickerItemViewModelDelegate {
  func productColorPickerItemViewModel(_ viewModel: ProductColorPickerItemViewModel,
                                       didSetSelectedState isSelected: Bool, allowsDeselection: Bool) {
    if let index = itemViewModels.firstIndex(where: { $0 === viewModel }),
       let color = productColors.element(at: index) {
      if isSelected {
        selectedColors.insert(color)
      } else {
        selectedColors.remove(color)
      }
      
      delegate?.subcategoryColorFilterSectionViewModel(self, didUpdateSelectedColors: Array(selectedColors))
    }
  }
}
