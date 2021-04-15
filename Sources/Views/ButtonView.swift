//
//  ButtonView.swift
//  ForwardLeasing
//

import UIKit

class ButtonView: UIView {
  // MARK: - Properties
  var onDidTap: (() -> Void)?

  // MARK: - Configure
  func configure(with view: UIView) {
    subviews.forEach { $0.removeFromSuperview() }
    addSubview(view)
    view.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    let button = UIButton()
    addSubview(button)
    button.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
  }

  // MARK: - Actions
  @objc private func buttonTapped() {
    onDidTap?()
  }
}
