//
//  ProductDescriptionViewModel.swift
//  ForwardLeasing
//

import Foundation

class ProductDescriptionViewModel: ProductDescriptionViewModelProtocol {
  // MARK: - Properties
  let descriptions: [ProductDescriptionConfiguration]
  let nameTitle: String
  let paymentTitle: String

  // MARK: - Init
  init(descriptions: [ProductDescriptionConfiguration],
       nameTitle: String,
       paymentTitle: String) {
    self.descriptions = descriptions
    self.nameTitle = nameTitle
    self.paymentTitle = paymentTitle
  }
}
