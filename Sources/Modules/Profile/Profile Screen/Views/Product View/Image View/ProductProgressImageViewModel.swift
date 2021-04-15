//
//  ProductProgressImageViewModel.swift
//  ForwardLeasing
//

import UIKit

class ProductProgressImageViewModel: ProductProgressImageViewModelProtocol {
  // MARK: - Properties
  let circleProgressInfo: CircleProgressInfo
  let productImageViewModel: ProductImageViewModelProtocol
  let insets: ProgressImageViewInsets

  // MARK: - Init
  init(circleProgressInfo: CircleProgressInfo,
       productImageViewModel: ProductImageViewModelProtocol,
       insets: ProgressImageViewInsets) {
    self.circleProgressInfo = circleProgressInfo
    self.productImageViewModel = productImageViewModel
    self.insets = insets
  }
}
