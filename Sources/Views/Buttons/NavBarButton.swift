//
//  NavBarButton.swift
//  ForwardLeasing
//

import UIKit

private extension Constants {
  static let buttonSideLength: CGFloat = 32
}

class NavBarButton: UIButton {
  override var isHighlighted: Bool {
    didSet {
      alpha = isHighlighted ? 0.2 : 1
    }
  }

  override var intrinsicContentSize: CGSize {
    return CGSize(width: Constants.buttonSideLength, height: Constants.buttonSideLength)
  }

  private var onDidTap: (() -> Void)

  init(image: UIImage?, onDidTap: @escaping (() -> Void)) {
    self.onDidTap = onDidTap
    super.init(frame: .zero)
    addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @objc private func handleTap() {
    onDidTap()
  }
}
