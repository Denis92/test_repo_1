//
//  ProductProgressImageViewInsets.swift
//  ForwardLeasing
//

import UIKit

struct ProductProgressImageViewInsets: ProgressImageViewInsets {
  let verticalInset: CGFloat
  let horizontalInset: CGFloat

  init(type: ProductType) {
    verticalInset = type == .appliances ? 16 : 10
    horizontalInset = type == .appliances ? 14 : 10
  }
}
