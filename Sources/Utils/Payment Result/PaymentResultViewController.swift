//
//  PaymentResultViewController.swift
//  ForwardLeasing
//

import UIKit

protocol PaymentResultViewControllerDelegate: class {
  func paymentResultViewControllerDidRequestClose(_ viewController: PaymentResultViewController)
}

class PaymentResultViewController: BaseViewController {
  // MARK: - Subviews
  private let resultIcon = UIImageView()
  private let contentView = UIView()
  private let containerView = UIView()
  private let closeButton = UIButton()
  private let titleLabel = AttributedLabel(textStyle: .title3Semibold)
  private let subtitleLabel = AttributedLabel(textStyle: .textRegular)
  
  // MARK: - Properties
  weak var delegate: PaymentResultViewControllerDelegate?
  
  private let isSuccess: Bool
  
  // MARK: - Init
  init(isSuccess: Bool) {
    self.isSuccess = isSuccess
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  // MARK: - Private Methods
  private func setup() {
    view.backgroundColor = .clear
    setupContentView()
    setupContainerView()
    setupCloseButton()
    setupResultIcon()
    setupTitleLabel()
    setupSubtitleLabel()
  }
  
  private func setupContentView() {
    view.addSubview(contentView)
    contentView.backgroundColor = .clear
    contentView.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.leading.trailing.equalToSuperview().inset(40)
    }
  }
  
  private func setupContainerView() {
    contentView.addSubview(containerView)
    containerView.backgroundColor = .base2
    containerView.makeRoundedCorners(radius: 8)
    containerView.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(47)
      make.leading.trailing.equalToSuperview()
      make.bottom.equalToSuperview()
    }
  }
  
  private func setupCloseButton() {
    containerView.addSubview(closeButton)
    closeButton.setImage(R.image.closePopupIcon(), for: .normal)
    closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
    closeButton.snp.makeConstraints { make in
      make.top.trailing.equalToSuperview().inset(8)
    }
  }
  
  private func setupResultIcon() {
    contentView.addSubview(resultIcon)
    resultIcon.contentMode = .scaleAspectFit
    resultIcon.image = isSuccess ? R.image.successIcon() : R.image.failedIcon()
    resultIcon.snp.makeConstraints { make in
      make.size.equalTo(94)
      make.top.equalToSuperview()
      make.centerX.equalToSuperview()
    }
  }
  
  private func setupTitleLabel() {
    contentView.addSubview(titleLabel)
    titleLabel.text = isSuccess ?
      R.string.paymentRegistration.successPaymentTitle() :
      R.string.paymentRegistration.failedPaymentTitle()
    titleLabel.textAlignment = .center
    titleLabel.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(110)
      make.leading.trailing.equalToSuperview()
    }
  }
  
  private func setupSubtitleLabel() {
    contentView.addSubview(subtitleLabel)
    subtitleLabel.text = isSuccess ?
      R.string.paymentRegistration.successPaymentSubtitle():
      R.string.paymentRegistration.failedPaymentSubtitle()
    subtitleLabel.numberOfLines = 0
    subtitleLabel.textAlignment = .center
    subtitleLabel.lineBreakMode = .byWordWrapping
    subtitleLabel.sizeToFit()
    subtitleLabel.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(8)
      make.leading.trailing.equalToSuperview().inset(40)
      make.bottom.equalToSuperview().inset(28)
    }
  }
  
  // MARK: - Actions
  @objc private func didTapClose() {
    delegate?.paymentResultViewControllerDidRequestClose(self)
  }
}
