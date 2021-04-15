//
//  SubcategoryFilterSectionViewModel.swift
//  ForwardLeasing
//

import Foundation

protocol SubcategoryFilterSectionViewModelDelegate: class {
  func subcategoryFilterSectionViewModel(_ viewModel: SubcategoryFilterSectionViewModel, didChangeFilter filter: Filter)
}

class SubcategoryFilterSectionViewModel {
  var title: String? {
    return filter.title
  }

  weak var delegate: SubcategoryFilterSectionViewModelDelegate?

  private (set) var itemViewModels: [SubcategoryFilterElementViewModel] = []

  private var filter: Filter

  init(filter: Filter) {
    self.filter = filter
    itemViewModels = filter.options.map {
      let viewModel = SubcategoryFilterElementViewModel(filterOption: $0)
      viewModel.delegate = self
      return viewModel
    }
  }

  func reset() {
    itemViewModels.forEach { $0.deselect() }
  }
}

// MARK: - SubcategoryFilterElementViewModelDelegate

extension SubcategoryFilterSectionViewModel: SubcategoryFilterElementViewModelDelegate {
  func subcategoryFilterElementViewModelDidRequestToggleFilterSelection(_ viewModel: SubcategoryFilterElementViewModel) {
    if viewModel.isSelected { // will be deselected
      viewModel.deselect()
    } else { // will be selected
      switch filter.filterType {
      case .singleOptionOnly:
        let selectedViewModels = itemViewModels.filter { $0.isSelected && !($0 === viewModel) }
        selectedViewModels.forEach { $0.deselect() } // deselect others
        viewModel.select()
      case .multipleOptions:
        viewModel.select()
      }
    }
  }

  func subcategoryFilterElementViewModel(_ viewModel: SubcategoryFilterElementViewModel,
                                         didFinishTogglingFilterSelection filterOption: FilterOption) {
    if let index = filter.options.firstIndex(where: { $0 == filterOption }) {
      filter.options[index] = filterOption
    }
    delegate?.subcategoryFilterSectionViewModel(self, didChangeFilter: filter)
  }
}
