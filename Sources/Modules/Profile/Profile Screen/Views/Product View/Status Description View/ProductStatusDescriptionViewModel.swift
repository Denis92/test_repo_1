//
//  ProductStatusDescriptionViewModel.swift
//  ForwardLeasing
//

import Foundation

class ProductStatusDescriptionViewModel: ProductStatusDescriptionViewModelProtocol, StackViewItemViewModel {
  // MARK: - Properties
  var itemViewIdentifier: String {
    return ProductStatusDescriptionView.reuseIdentifier
  }
  
  let productDescriptionConfiguration: ProductDescriptionConfiguration

  // MARK: - Init
  init(productDescriptionConfiguration: ProductDescriptionConfiguration) {
    self.productDescriptionConfiguration = productDescriptionConfiguration
  }
}
