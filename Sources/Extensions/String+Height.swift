//
//  String+Height.swift
//  ForwardLeasing
//

import UIKit

extension String {
  func height(forContainerWidth width: CGFloat, textStyle: TextStyle) -> CGFloat {
    let attributedString = createAttributedString(with: textStyle.font, lineHeightMultiple: textStyle.lineHeightMultiple)
    return attributedString.textHeight(forContainerWidth: width)
  }

  func width(forContainerHeight height: CGFloat, textStyle: TextStyle) -> CGFloat {
    let attributedString = createAttributedString(with: textStyle.font, lineHeightMultiple: textStyle.lineHeightMultiple)
    return attributedString.textWidth(forContainerHeight: height)
  }

  private func createAttributedString(with font: UIFont, lineHeightMultiple: CGFloat) -> NSAttributedString {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineHeightMultiple = lineHeightMultiple
    let attributes: [NSAttributedString.Key: Any] = [.font: font,
                                                     .paragraphStyle: paragraphStyle]
    return NSAttributedString(string: self, attributes: attributes)
  }
}
