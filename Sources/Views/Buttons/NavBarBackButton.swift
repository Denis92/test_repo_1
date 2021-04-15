//
//  NavBarBackButton.swift
//  ForwardLeasing
//

import UIKit

private extension Constants {
  static let buttonHeight: CGFloat = 32
  static let buttonWidth: CGFloat = 44
}

class NavBarBackButton: UIButton {
  override var isHighlighted: Bool {
    didSet {
      alpha = isHighlighted ? 0.2 : 1
    }
  }

  override var intrinsicContentSize: CGSize {
    return CGSize(width: Constants.buttonWidth, height: Constants.buttonHeight)
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    setImage(R.image.backButtonWithBackgroundIcon()?.withRenderingMode(.alwaysOriginal), for: .normal)
    imageEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 6)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
