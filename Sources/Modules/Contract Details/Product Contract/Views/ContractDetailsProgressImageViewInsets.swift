//
//  ContractDetailsProgressImageViewInsets.swift
//  ForwardLeasing
//

import UIKit

struct ContractDetailsProgressImageViewInsets: ProgressImageViewInsets {
  let verticalInset: CGFloat
  let horizontalInset: CGFloat

  init(type: ProductType) {
    verticalInset = type == .appliances ? 24 : 10
    horizontalInset = type == .appliances ? 21 : 10
  }
}
