//
//  PinAsset.swift
//  ForwardLeasing
//

import UIKit

enum PinAsset {
  case selected(isEnabled: Bool)
  case notSelected(isEnabled: Bool)
  
  init(isEnabled: Bool, isSelected: Bool) {
    self = isSelected ? .selected(isEnabled: isEnabled) : .notSelected(isEnabled: isEnabled)
  }
  
  var icon: UIImage? {
    switch self {
    case .selected(let isEnabled):
      return isEnabled ? R.image.pickPointSelected() : R.image.disablePickPointSelected()
    case .notSelected(let isEnabled):
      return isEnabled ? R.image.pickPointNotSelected() : R.image.disablePickPointNotSelected()
    }
  }
}
