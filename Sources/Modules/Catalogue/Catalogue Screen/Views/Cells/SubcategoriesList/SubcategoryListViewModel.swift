//
//  SubcatigoryCellViewModel.swift
//  ForwardLeasing
//

import UIKit

protocol SubcategoryListViewModelDelegate: class {
  func subcategoryListViewModel(_ viewModel: SubcategoryListViewModel, didSelectSubcategory subcategory: Subcategory)
}

class SubcategoryListViewModel: CommonTableCellViewModel {
  var tableCellIdentifier: String {
    return CommonContainerTableViewCell<SubcategoryListView>.reuseIdentifier
  }

  var contentInsets: UIEdgeInsets {
    return UIEdgeInsets(top: 16, left: 0, bottom: 24, right: 0)
  }

  weak var delegate: SubcategoryListViewModelDelegate?

  private (set) var itemViewModels: [SubcategoryCellViewModel] = []

  init(subcategoriesList: [Subcategory]) {
    self.itemViewModels = subcategoriesList.map {
      let viewModel = SubcategoryCellViewModel(subcategory: $0)
      viewModel.delegate = self
      return viewModel
    }
  }
}

extension SubcategoryListViewModel: SubcategoryCellViewModelDelegate {
  func subcategoryCellViewModel(_ viewModel: SubcategoryCellViewModel, didSelectSubcategory subcategory: Subcategory) {
    delegate?.subcategoryListViewModel(self, didSelectSubcategory: subcategory)
  }
}
