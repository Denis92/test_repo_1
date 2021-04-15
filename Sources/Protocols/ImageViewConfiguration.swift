//
//  ImageViewConfiguration.swift
//  ForwardLeasing
//

import UIKit

protocol ImageViewConfiguration {
  var contentMode: UIView.ContentMode { get }
}

struct DefaultImageViewConfiguration: ImageViewConfiguration {
  let contentMode: UIView.ContentMode

  init(type: ProductType) {
    switch type {
    case .smartphone:
      contentMode = .scaleAspectFill
    default:
      contentMode = .scaleAspectFit
    }
  }
}
