//
//  ProductDeliveryViewModel.swift
//  ForwardLeasing
//

import UIKit

class ProductDeliveryViewModel: ProductDeliveryViewModelProtocol, StackViewItemViewModel {
  // MARK: - Properties
  var itemViewIdentifier: String {
    return ProductDeliveryView.reuseIdentifier
  }
  
  let currentStep: Int
  let stepsCount: Int
  let description: String
  let descriptionColor: UIColor
  
  // MARK: - Init
  init(currentStep: Int,
       stepsCount: Int,
       description: String,
       descriptionColor: UIColor) {
    self.currentStep = currentStep
    self.stepsCount = stepsCount
    self.description = description
    self.descriptionColor = descriptionColor
  }
}
