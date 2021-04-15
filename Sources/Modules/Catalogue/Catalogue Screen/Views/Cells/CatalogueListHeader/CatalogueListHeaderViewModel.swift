//
//  CatalogueListHeaderViewModel.swift
//  ForwardLeasing
//

import Foundation

struct CatalogueListHeaderViewModel: CommonTableHeaderFooterViewModel {
  var headerFooterReuseIdentifier: String {
    return CommonContainerHeaderFooterView<CatalogueListHeaderView>.reuseIdentifier
  }

  var title: String? {
    return category.title
  }

  let category: Category

  init(category: Category) {
    self.category = category
  }
}
