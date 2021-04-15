//
//  HighlightableButton.swift
//  ForwardLeasing
//

import UIKit

class HighlightableButton: UIButton {
  var onHighlightedChanged: ((Bool) -> Void)?

  override var isHighlighted: Bool {
    didSet {
      onHighlightedChanged?(isHighlighted)
    }
  }
}
