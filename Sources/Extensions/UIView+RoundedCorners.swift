//
//  UIView+RoundedCorners.swift
//  ForwardLeasing
//

import UIKit

extension UIView {
  func makeRoundedCorners(masksToBounds: Bool = true) {
    makeRoundedCorners(radius: bounds.height / 2,
                       masksToBounds: masksToBounds)
  }

  func makeRoundedCorners(radius: CGFloat, masksToBounds: Bool = true) {
    layer.cornerRadius = radius
    layer.masksToBounds = masksToBounds
  }
  
  func makeRoundedCorners(corners: CACornerMask, radius: CGFloat) {
    layer.cornerRadius = radius
    layer.maskedCorners = corners
  }
}
