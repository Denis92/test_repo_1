//
//  ProductImageCarouselViewModel.swift
//  ForwardLeasing
//

import UIKit

class ProductImageCarouselViewModel: CommonCollectionViewModel, ProductDetailsItemViewModel {
  var collectionCellViewModels: [CommonCollectionCellViewModel] {
    return itemViewModels
  }
  
  var itemsCount: Int {
    return itemViewModels.count
  }
  
  let type: ProductDetailsItemType = .imageCarousel
  let customSpacing: CGFloat? = 38

  private var itemViewModels: [ProductImageCarouselItemViewModel] = []
  
  init(images: [ImageInfo], type: ProductType) {
    images.forEach { image in
      itemViewModels.append(ProductImageCarouselItemViewModel(link: image.imageLink, type: type))
    }
  }
}
