//
//  UImage+Color.swift
//  ForwardLeasing
//

import UIKit

extension UIImage {
  convenience init?(color: UIColor) {
    let frame = CGRect(x: 0, y: 0, width: 1, height: 1)
    UIGraphicsBeginImageContext(frame.size)
    let context = UIGraphicsGetCurrentContext()
    context?.setFillColor(color.cgColor)
    context?.fill(frame)
    let image = context?.makeImage()
    UIGraphicsEndImageContext()
    guard let cgImage = image else { return nil }
    self.init(cgImage: cgImage)
  }
}
