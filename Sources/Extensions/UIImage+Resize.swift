//
//  UIImage+Resize.swift
//  ForwardLeasing
//

import UIKit

extension UIImage {
  func resize(to minSide: CGFloat) -> UIImage {
    let oldWidth = size.width
    let oldHeight = size.height
    let scaleFactor = (minSide / UIScreen.main.scale) / min(oldWidth, oldHeight)
    guard abs(scaleFactor - 1) >= 0.2 else { return self }
    let newHeight = oldHeight * scaleFactor
    let newWidth = oldWidth * scaleFactor
    let newSize = CGSize(width: newWidth, height: newHeight)
    let renderer = UIGraphicsImageRenderer(size: newSize)
    let image = renderer.image { _ in
      draw(in: CGRect(origin: CGPoint.zero, size: newSize))
    }
    return image
  }
}
