//
//  ProductImageCarouselItemViewModel.swift
//  ForwardLeasing
//

import Foundation

class ProductImageCarouselItemViewModel {
  let imageURL: URL?
  let imageViewConfiguration: ImageViewConfiguration

  
  init(link: String, type: ProductType) {
    imageURL = link.toURL()
    imageViewConfiguration = DefaultImageViewConfiguration(type: type)
  }
}

extension ProductImageCarouselItemViewModel: CommonCollectionCellViewModel {
  var collectionCellIdentifier: String {
    return CommonConfigurableCollectionViewCell<ProductImageCarouselItemView>.reuseIdentifier
  }
}
