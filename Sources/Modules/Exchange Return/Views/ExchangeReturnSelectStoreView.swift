//
//  ExchangeReturnSelectStoreView.swift
//  ForwardLeasing
//

import UIKit

class ExchangeReturnSelectStoreView: UIView, Configurable {
  // MARK: - Properties
  
  private let titleLabel = AttributedLabel(textStyle: .title2Bold)
  private let selectStoreButton = UIButton(type: .system)
  
  private var didTapButton: (() -> Void)?
  
  // MARK: - Init
  
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure
  
  func configure(with viewModel: ExchangeReturnSelectStoreViewModel) {
    titleLabel.text = viewModel.title
    didTapButton = { [weak viewModel] in
      viewModel?.didTapSelectStoreButton()
    }
  }
  
  // MARK: - Actions
  
  @objc private func didTapSelectStoreButton() {
    didTapButton?()
  }
  
  // MARK: - Setup
  
  private func setup() {
    setupTitleLabel()
    setupSelectStoreButton()
  }
  
  private func setupTitleLabel() {
    addSubview(titleLabel)
    titleLabel.numberOfLines = 0
    titleLabel.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }
  
  private func setupSelectStoreButton() {
    addSubview(selectStoreButton)
    selectStoreButton.layer.cornerRadius = 20
    selectStoreButton.layer.borderWidth = 1
    selectStoreButton.layer.borderColor = UIColor.accent.cgColor
    selectStoreButton.setTitle(R.string.exchangeInfo.selectStoreButtonTitle(), for: .normal)
    selectStoreButton.setImage(R.image.mapPinIcon(), for: .normal)
    selectStoreButton.tintColor = .accent
    selectStoreButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 34)
    selectStoreButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: -10)
    selectStoreButton.semanticContentAttribute = UIApplication.shared
        .userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft
    selectStoreButton.addTarget(self, action: #selector(didTapSelectStoreButton), for: .touchUpInside)
    selectStoreButton.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(24)
      make.leading.equalToSuperview().inset(20)
      make.bottom.equalToSuperview().inset(32)
      make.height.equalTo(40)
    }
  }
}
