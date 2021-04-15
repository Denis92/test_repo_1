//
//  Switch.swift
//  ForwardLeasing
//

import UIKit

class Switch: UISwitch {
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    onTintColor = .accent
  }
}
