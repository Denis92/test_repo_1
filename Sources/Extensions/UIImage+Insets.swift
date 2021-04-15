//
//  UIImage+insets.swift
//  ForwardLeasing
//

import UIKit

extension UIImage {
  func with(insets: UIEdgeInsets) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(CGSize(width: size.width + insets.left + insets.right,
                                                  height: size.height + insets.top + insets.bottom), false, self.scale)

    let origin = CGPoint(x: insets.left, y: insets.top)
    self.draw(at: origin)
    let imageWithInsets = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return imageWithInsets
  }
}
