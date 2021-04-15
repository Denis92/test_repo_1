//
//  ProductFullFeaturesViewModel.swift
//  ForwardLeasing
//

import UIKit

class ProductFullFeaturesViewModel: ProductDetailsItemViewModel {
  let productDescription: String?
  let type: ProductDetailsItemType = .fullFeatures
  let customSpacing: CGFloat? = nil

  var secondaryFeatures: [ProductFeature] {
    return features.filter { $0.type == .secondary }
  }

  var isHidden: Bool {
    return productDescription.isEmptyOrNil && secondaryFeatures.isEmpty
  }

  private let features: [ProductFeature]
  
  init(description: String?, features: [ProductFeature]) {
    self.productDescription = description
    self.features = features
  }
}
