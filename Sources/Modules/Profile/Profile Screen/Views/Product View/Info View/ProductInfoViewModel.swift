//
//  ProductInfoViewModel.swift
//  ForwardLeasing
//

import Foundation

class ProductInfoViewModel: ProductInfoViewModelProtocol, StackViewItemViewModel {
  // MARK: - Properties
  var itemViewIdentifier: String {
    return ProductInfoView.reuseIdentifier
  }

  let descriptionViewModel: ProductDescriptionViewModelProtocol
  let imageViewType: ImageViewType

  // MARK: - Init
  init(descriptionViewModel: ProductDescriptionViewModelProtocol,
       imageViewType: ImageViewType) {
    self.descriptionViewModel = descriptionViewModel
    self.imageViewType = imageViewType
  }
}
