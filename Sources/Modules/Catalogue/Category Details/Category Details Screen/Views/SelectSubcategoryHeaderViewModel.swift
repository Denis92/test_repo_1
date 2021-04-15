//
//  SelectSubcategoryHeaderViewModel.swift
//  ForwardLeasing
//

import Foundation

protocol SelectSubcategoryHeaderViewModelDelegate: class {
  func selectSubcategoryHeaderViewModel(_ viewModel: SelectSubcategoryHeaderViewModel,
                                        didRequestChooseSubcategoryWithCurrent selectedSubcategory: Subcategory?)
}

class SelectSubcategoryHeaderViewModel: SelectSubcategoryHeaderViewModelProtocol {
  var selectedSubcategoryTitle: String? {
    guard let subcategory = selectedSubcategory else {
      return R.string.catalogue.selectSubcategoryDropdownAllCategoriesText()
    }
    return subcategory.title
  }
  
  var onDidUpdateSelectedSubcategoryTitle: ((String?) -> Void)?
  
  weak var delegate: SelectSubcategoryHeaderViewModelDelegate?
  
  private var selectedSubcategory: Subcategory? {
    didSet {
      if oldValue != selectedSubcategory {
        onDidUpdateSelectedSubcategoryTitle?(selectedSubcategoryTitle)
      }
    }
  }
  
  init(selectedSubcategory: Subcategory?) {
    self.selectedSubcategory = selectedSubcategory
  }
  
  func selectSubcategory() {
    delegate?.selectSubcategoryHeaderViewModel(self, didRequestChooseSubcategoryWithCurrent: selectedSubcategory)
  }
  
  func update(subcategory: Subcategory?) {
    selectedSubcategory = subcategory
  }
}
