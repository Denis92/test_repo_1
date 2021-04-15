//
//  ProductFeaturesViewModel.swift
//  ForwardLeasing
//

import UIKit

class ProductFeaturesViewModel: CommonCollectionViewModel, ProductDetailsItemViewModel {
  var collectionCellViewModels: [CommonCollectionCellViewModel] {
    return features.filter { $0.type == .image }
      .map { ProductFeaturesCarouselItemViewModel(imageURL: $0.imageLink.toURL(),
                                                  title: $0.content) }
  }
  var mainFeatures: [ProductFeature] {
    return features.filter { $0.type == .main }
  }
  
  let type: ProductDetailsItemType = .features
  let customSpacing: CGFloat? = nil

  private let features: [ProductFeature]
  
  init(features: [ProductFeature]) {
    self.features = features
  }
}
