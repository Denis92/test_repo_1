//
//  ProductImageViewModel.swift
//  ForwardLeasing
//

import Foundation

class ProductImageViewModel: ProductImageViewModelProtocol {
  // MARK: - Properties
  let imageURL: URL?
  let imageViewConfiguration: ImageViewConfiguration
  let type: ProductType

  // MARK: - Init
  // TODO: Remove default value
  init(imageURL: URL?, type: ProductType = .smartphone) {
    self.imageURL = imageURL
    self.imageViewConfiguration = DefaultImageViewConfiguration(type: type)
    self.type = type
  }
}
