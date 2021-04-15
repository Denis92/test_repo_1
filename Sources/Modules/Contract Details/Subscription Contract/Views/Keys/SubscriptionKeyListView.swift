//
//  SubscriptionKeyListView.swift
//  ForwardLeasing
//

import UIKit

protocol SubscriptionKeyListViewModelProtocol: class {
  var keyViewModels: [SubscriptionKeyViewModelProtocol] { get }
  
  func shareKeys()
}

class SubscriptionKeyListView: UIView {
  private let titleLabel = AttributedLabel(textStyle: .title2Bold)
  private let stackView = UIStackView()
  private let shareButton = StandardButton(type: .primary)

  private var onShareButtonTapped: (() -> Void)?

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

  func configure(with viewModel: SubscriptionKeyListViewModelProtocol) {
    stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    for keyModel in viewModel.keyViewModels {
      let view = SubscriptionKeyView()
      view.configure(with: keyModel)
      stackView.addArrangedSubview(view)
    }
    onShareButtonTapped = { [weak viewModel] in
      viewModel?.shareKeys()
    }
  }

  // MARK: - Setup
  private func setup() {
    addTitleLabel()
    addStackView()
    addShareButton()
  }

  private func addTitleLabel() {
    addSubview(titleLabel)
    titleLabel.snp.makeConstraints { make in
      make.leading.top.equalToSuperview()
      make.height.equalTo(24)
    }
    titleLabel.text = R.string.subscriptionDetails.subscriptionKeysSectionTitle()
  }

  private func addStackView() {
    addSubview(stackView)
    stackView.axis = .vertical
    stackView.distribution = .equalSpacing
    stackView.spacing = 8
    stackView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.top.equalTo(titleLabel.snp.bottom).offset(16)
    }
  }

  private func addShareButton() {
    addSubview(shareButton)
    shareButton.setTitle(R.string.subscriptionDetails.shareButtonTitle(), for: .normal)
    shareButton.addTarget(self, action: #selector(handleShareButtonTapped(_:)), for: .touchUpInside)
    shareButton.snp.makeConstraints { make in
      make.top.equalTo(stackView.snp.bottom).offset(16)
      make.leading.trailing.equalToSuperview()
      make.bottom.equalToSuperview().inset(32)
    }
  }

  // MARK: - Actions

  @objc private func handleShareButtonTapped(_ sender: UIButton) {
    onShareButtonTapped?()
  }
}
