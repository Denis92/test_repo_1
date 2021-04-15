//
//  DeniedView.swift
//  ForwardLeasing
//

import UIKit

struct DeniedViewModel {
  let title: String
  let buttonTitle: String
  let onDidTap: (() -> Void)?
}

class DeniedView: UIView, Configurable {
  // MARK: - Subviews
  private let containerView = UIImageView()
  private let failImageView = UIImageView()
  private let titleLabel = AttributedLabel(textStyle: .title2Bold)
  private let bottomButton = StandardButton(type: .primary)
  
  var onDidTap: (() -> Void)?
  
  // MARK: - Init
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Public
  func configure(with viewModel: DeniedViewModel) {
    onDidTap = viewModel.onDidTap
    titleLabel.text = viewModel.title
    bottomButton.setTitle(viewModel.buttonTitle, for: .normal)
  }
  
  // MARK: - Setup
  private func setup() {
    setupContainerView()
    setupFailImageView()
    setupTitleLabel()
    setupBottomButton()
  }
  
  private func setupContainerView() {
    addSubview(containerView)
    containerView.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }
  
  private func setupFailImageView() {
    containerView.addSubview(failImageView)
    failImageView.image = R.image.failImage()
    failImageView.contentMode = .scaleAspectFit
    failImageView.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.centerX.equalToSuperview()
      make.size.equalTo(80)
    }
  }
  
  private func setupTitleLabel() {
    containerView.addSubview(titleLabel)
    titleLabel.text = R.string.sendingApplication.failViewTitleDenied()
    titleLabel.textAlignment = .center
    titleLabel.numberOfLines = 0
    titleLabel.snp.makeConstraints { make in
      make.top.equalTo(failImageView.snp.bottom).offset(32)
      make.leading.trailing.bottom.equalToSuperview()
      make.bottom.equalToSuperview()
    }
  }

  private func setupBottomButton() {
    addSubview(bottomButton)
    bottomButton.addTarget(self, action: #selector(didTapBottomButton), for: .touchUpInside)
    bottomButton.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(20)
      make.bottom.equalToSuperview().inset(40)
    }
  }
  
  @objc private func didTapBottomButton() {
    onDidTap?()
  }
}
