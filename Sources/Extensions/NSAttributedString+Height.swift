//
//  NSAttributedString+Height.swift
//  ForwardLeasing
//

import UIKit

extension NSAttributedString {
  func textHeight(forContainerWidth width: CGFloat) -> CGFloat {
    let rect = self.boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude),
                                 options: [.usesLineFragmentOrigin, .usesFontLeading],
                                 context: nil)
    let scale = UIScreen.main.scale
    return ceil(rect.size.height * scale) / scale
  }

  func textWidth(forContainerHeight height: CGFloat) -> CGFloat {
    let rect = self.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: height),
                                 options: [.usesLineFragmentOrigin, .usesFontLeading],
                                 context: nil)
    let scale = UIScreen.main.scale
    return ceil(rect.size.width * scale) / scale
  }
}
