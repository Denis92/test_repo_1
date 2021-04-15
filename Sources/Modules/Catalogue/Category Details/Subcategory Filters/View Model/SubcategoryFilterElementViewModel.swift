//
//  SubcategoryFilterElementViewModel.swift
//  ForwardLeasing
//

import Foundation

protocol SubcategoryFilterElementViewModelDelegate: class {
  func subcategoryFilterElementViewModelDidRequestToggleFilterSelection(_ viewModel: SubcategoryFilterElementViewModel)
  func subcategoryFilterElementViewModel(_ viewModel: SubcategoryFilterElementViewModel,
                                         didFinishTogglingFilterSelection filterOption: FilterOption)
}

class SubcategoryFilterElementViewModel: ProductPropertyPickerItemViewModelProtocol {
  var title: String? {
    return filterOption.title
  }

  var onDidUpdate: (() -> Void)?

  weak var delegate: SubcategoryFilterElementViewModelDelegate?

  let isEnabled: Bool = true

  private (set) var isSelected: Bool {
    didSet {
      if isSelected != oldValue {
        onDidUpdate?()
        filterOption.isSelected = isSelected
      }
    }
  }

  private var filterOption: FilterOption

  init(filterOption: FilterOption) {
    self.filterOption = filterOption
    self.isSelected = filterOption.isSelected
  }

  func toggleSelectionStateByTap() {
    delegate?.subcategoryFilterElementViewModelDidRequestToggleFilterSelection(self)
  }

  func select() {
    isSelected = true
    delegate?.subcategoryFilterElementViewModel(self, didFinishTogglingFilterSelection: filterOption)
  }

  func deselect() {
    isSelected = false
    delegate?.subcategoryFilterElementViewModel(self, didFinishTogglingFilterSelection: filterOption)
  }
}
