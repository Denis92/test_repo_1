//
//  SubcategoryCellViewModel.swift
//  ForwardLeasing
//

import Foundation

protocol SubcategoryCellViewModelDelegate: class {
  func subcategoryCellViewModel(_ viewModel: SubcategoryCellViewModel, didSelectSubcategory subcategory: Subcategory)
}

class SubcategoryCellViewModel {
  weak var delegate: SubcategoryCellViewModelDelegate?
  
  var title: String? {
    return subcategory.title
  }

  var imageURL: URL? {
    return subcategory.imageURL.toURL()
  }

  private let subcategory: Subcategory
  
  init(subcategory: Subcategory) {
    self.subcategory = subcategory
  }
  
  func selectSubcategory() {
    delegate?.subcategoryCellViewModel(self, didSelectSubcategory: subcategory)
  }
}
