//
//  ProductAdvantagesViewModel.swift
//  ForwardLeasing
//

import UIKit

class ProductAdvantagesViewModel: ProductDetailsItemViewModel {

  let itemViewModels: [ProductAdvantageItemViewModel]
  let type: ProductDetailsItemType = .advantages
  let customSpacing: CGFloat? = 24

  init(contentItems: [ProductContentItem]) {
    itemViewModels = contentItems.map { ProductAdvantageItemViewModel(contentItem: $0) }
  }
}
