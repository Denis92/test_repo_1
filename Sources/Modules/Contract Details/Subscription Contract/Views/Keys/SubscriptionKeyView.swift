//
//  SubscriptionKeyView.swift
//  ForwardLeasing
//

import UIKit

protocol SubscriptionKeyViewModelProtocol: class {
  var key: String { get }

  func copyKey()
}

class SubscriptionKeyView: UIView {
  private let codeLabel = AttributedLabel(textStyle: .textRegular)
  private let copyButton = UIButton(type: .system)

  private var onCopyButtonTapped: (() -> Void)?

  // MARK: - Init
  init() {
    super.init(frame: .zero)
    setup()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }

  // MARK: - Configure

  func configure(with viewModel: SubscriptionKeyViewModelProtocol) {
    codeLabel.text = viewModel.key
    onCopyButtonTapped = { [weak viewModel] in
      viewModel?.copyKey()
    }
  }

  // MARK: - Setup
  private func setup() {
    addCodeLabel()
    addCopyButton()
    backgroundColor = .shade20
    makeRoundedCorners(radius: 7)
  }

  private func addCodeLabel() {
    addSubview(codeLabel)
    codeLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().offset(10)
      make.top.bottom.equalToSuperview().inset(10)
    }
  }

  private func addCopyButton() {
    addSubview(copyButton)
    copyButton.snp.makeConstraints { make in
      make.width.equalTo(44)
      make.top.bottom.trailing.equalToSuperview()
      make.leading.greaterThanOrEqualTo(codeLabel.snp.trailing).offset(8)
    }
    copyButton.setImage(R.image.copy(), for: .normal)
    copyButton.tintColor = .accent
    copyButton.addTarget(self, action: #selector(handleCopyButtonTapped(_:)), for: .touchUpInside)
  }

  // MARK: - Actions

  @objc private func handleCopyButtonTapped(_ sender: UIButton) {
    onCopyButtonTapped?()
  }
}
