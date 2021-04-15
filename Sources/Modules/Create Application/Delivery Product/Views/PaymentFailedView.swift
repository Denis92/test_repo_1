//
//  PaymentFailedView.swift
//  ForwardLeasing
//

import UIKit

protocol PaymentFailedViewModelProtocol {
  var cancelTitle: String? { get }
  var onDidTapRepeat: (() -> Void)? { get }
  var onDidTapCheckLater: (() -> Void)? { get }
  var onDidTapCancel: (() -> Void)? { get }
}

class PaymentFailedView: UIView, Configurable {
  // MARK: - Subviews
  private let scrollView = UIScrollView()
  private let contentView = UIView()
  private let centerContainerView = UIView()
  private let iconView = UIImageView()
  private let titleLabel = AttributedLabel(textStyle: .title2Bold)
  private let subtitleLabel = AttributedLabel(textStyle: .textRegular)
  private let buttonsStack = UIStackView()
  private let repeatButton = StandardButton(type: .primary)
  private let checkLaterButton = StandardButton(type: .secondary)
  private let cancelButton = StandardButton(type: .clear)
  
  // MARK: - Properties
  private var onDidTapRepeat: (() -> Void)?
  private var onDidTapCheckLater: (() -> Void)?
  private var onDidTapCancel: (() -> Void)?
  
  // MARK: - Init
  
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }
  
  // MARK: - Public Methods
  
  func configure(with viewModel: PaymentFailedViewModelProtocol) {
    onDidTapRepeat = viewModel.onDidTapRepeat
    onDidTapCheckLater = viewModel.onDidTapCheckLater
    onDidTapCancel = viewModel.onDidTapCancel
    cancelButton.isHidden = viewModel.onDidTapCancel == nil
    cancelButton.setTitle(viewModel.cancelTitle, for: .normal)
  }
  
  // MARK: - Private Methods
  private func setup() {
    setupScrollView()
    setupContentView()
    setupIconView()
    setupCenterContainer()
    setupTitleLabel()
    setupSubtitleLabel()
    setupButtonsStack()
    setupRepeatButton()
    setupCheckLaterButton()
    setupCancelButton()
  }
  
  private func setupScrollView() {
    addSubview(scrollView)
    scrollView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    scrollView.contentInsetAdjustmentBehavior = .never
  }
  
  private func setupContentView() {
    scrollView.addSubview(contentView)
    contentView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.height.greaterThanOrEqualToSuperview()
      make.width.equalToSuperview()
    }
  }
  
  private func setupCenterContainer() {
    contentView.addSubview(centerContainerView)
    centerContainerView.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }
  
  private func setupIconView() {
    centerContainerView.addSubview(iconView)
    iconView.contentMode = .scaleAspectFit
    iconView.image = R.image.failureImage()
    iconView.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.size.equalTo(80)
      make.centerX.equalToSuperview()
    }
  }
  
  private func setupTitleLabel() {
    centerContainerView.addSubview(titleLabel)
    titleLabel.textColor = .base1
    titleLabel.textAlignment = .center
    titleLabel.numberOfLines = 2
    titleLabel.text = R.string.deliveryProduct.deliveryPaymentFailedTitle()
    titleLabel.snp.makeConstraints { make in
      make.top.equalTo(iconView.snp.bottom).offset(32)
      make.leading.trailing.equalToSuperview()
    }
  }
  
  private func setupSubtitleLabel() {
    centerContainerView.addSubview(subtitleLabel)
    subtitleLabel.textColor = .base1
    subtitleLabel.textAlignment = .center
    subtitleLabel.numberOfLines = 0
    subtitleLabel.text = R.string.deliveryProduct.deliveryPaymentFailedSubtitle()
    subtitleLabel.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(16)
      make.leading.trailing.equalToSuperview()
      make.bottom.equalToSuperview()
    }
  }
  
  private func setupButtonsStack() {
    contentView.addSubview(buttonsStack)
    buttonsStack.axis = .vertical
    buttonsStack.spacing = 16
    buttonsStack.snp.makeConstraints { make in
      make.top.greaterThanOrEqualTo(centerContainerView.snp.bottom).offset(16)
      make.leading.trailing.equalToSuperview().inset(20)
      make.bottom.equalToSuperview().inset(40)
    }
  }
  
  private func setupRepeatButton() {
    buttonsStack.addArrangedSubview(repeatButton)
    repeatButton.setTitle(R.string.deliveryProduct.repeatPaymentButtonTitle(), for: .normal)
    repeatButton.actionHandler(controlEvents: .touchUpInside) { [weak self] in
      self?.onDidTapRepeat?()
    }
  }
  
  private func setupCheckLaterButton() {
    buttonsStack.addArrangedSubview(checkLaterButton)
    checkLaterButton.setTitle(R.string.deliveryProduct.checkLaterButtonTitle(), for: .normal)
    checkLaterButton.actionHandler(controlEvents: .touchUpInside) { [weak self] in
      self?.onDidTapCheckLater?()
    }
  }
  
  private func setupCancelButton() {
    buttonsStack.addArrangedSubview(cancelButton)
    cancelButton.actionHandler(controlEvents: .touchUpInside) { [weak self] in
      self?.onDidTapCancel?()
    }
  }
}
