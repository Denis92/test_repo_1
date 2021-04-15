//
//  ProductFeaturesCarouselItemViewModel.swift
//  ForwardLeasing
//

import Foundation

struct ProductFeaturesCarouselItemViewModel: CommonCollectionCellViewModel {
  var collectionCellIdentifier: String {
    return CommonConfigurableCollectionViewCell<ProductFeatureCarouselItemView>.reuseIdentifier
  }
  
  let imageURL: URL?
  let title: String?
}
