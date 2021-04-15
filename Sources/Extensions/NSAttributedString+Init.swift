//
//  NSAttributedString+Init.swift
//  ForwardLeasing
//

import UIKit

extension NSAttributedString {
  convenience init(string: String, font: UIFont, foregroundColor: UIColor, lineSpacing: CGFloat? = nil) {
    let paragraphStyle = NSMutableParagraphStyle()
    if let lineSpacing = lineSpacing {
      paragraphStyle.lineSpacing = lineSpacing
    }
    paragraphStyle.alignment = .center
    let attributes: [NSAttributedString.Key: Any] = [
      .font: font,
      .foregroundColor: foregroundColor,
      .paragraphStyle: paragraphStyle
    ]
    self.init(string: string, attributes: attributes)
  }
  
}
