//
//  SubcategoryFiltersViewModel.swift
//  ForwardLeasing
//

import Foundation

protocol SubcategoryFiltersViewModelDelegate: class {
  func subcategoryFiltersViewModel(_ viewModel: SubcategoryFiltersViewModel, didFinishWithFilters filters: [Filter],
                                   colorFilters: [ColorFilter])
}

class SubcategoryFiltersViewModel {
  weak var delegate: SubcategoryFiltersViewModelDelegate?

  private var filters: [Filter]
  private var colorFilters: [ColorFilter]
  private (set) var filterViewModels: [SubcategoryFilterSectionViewModel] = []
  private (set) var colorFilterViewModels: [SubcategoryColorFilterSectionViewModel] = []

  init(filters: [Filter], colorFilters: [ColorFilter]) {
    self.filters = filters
    self.colorFilters = colorFilters
    filterViewModels = filters.map {
      let viewModel = SubcategoryFilterSectionViewModel(filter: $0)
      viewModel.delegate = self
      return viewModel
    }
    colorFilterViewModels = colorFilters.map {
      let viewModel = SubcategoryColorFilterSectionViewModel(colorFilter: $0)
      viewModel.delegate = self
      return viewModel
    }
  }

  func finish() {
    delegate?.subcategoryFiltersViewModel(self, didFinishWithFilters: filters, colorFilters: colorFilters)
  }

  func reset() {
    filterViewModels.forEach { $0.reset() }
    colorFilterViewModels.forEach { $0.reset() }
  }
}

// MARK: - SubcategoryFilterSectionViewModelDelegate

extension SubcategoryFiltersViewModel: SubcategoryFilterSectionViewModelDelegate {
  func subcategoryFilterSectionViewModel(_ viewModel: SubcategoryFilterSectionViewModel, didChangeFilter filter: Filter) {
    if let index = filters.firstIndex(where: { $0 == filter }) {
      filters[index] = filter
    }
  }
}

// MARK: - SubcategoryColorFilterSectionViewModelDelegate

extension SubcategoryFiltersViewModel: SubcategoryColorFilterSectionViewModelDelegate {
  func subcategoryColorFilterSectionViewModel(_ viewModel: SubcategoryColorFilterSectionViewModel,
                                              didUpdateSelectedColors colors: [ProductColor]) {
    if let index = colorFilterViewModels.firstIndex(where: { $0 === viewModel }),
       var colorFilter = colorFilters.element(at: index) {
      for (index, option) in colorFilter.options.enumerated() {
        colorFilter.options[index].isSelected = colors.contains(option.color)
      }
      colorFilters[index] = colorFilter
    }
  }
}
