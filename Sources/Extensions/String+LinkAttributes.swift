//
//  String+LinkAttributes.swift
//  ForwardLeasing
//

import UIKit

extension String {
  var linkAttributes: [NSAttributedString.Key: Any] {
    var attributes: [NSAttributedString.Key: Any] = [:]
    attributes[NSAttributedString.Key.link] = self
    attributes[NSAttributedString.Key.font] = UIFont.textBold
    return attributes
  }
}
