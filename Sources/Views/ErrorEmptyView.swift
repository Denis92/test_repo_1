//
//  ErrorEmptyView.swift
//  ForwardLeasing
//

import UIKit

class ErrorEmptyView: UIView {
  // MARK: - Properties
  var onRefreshTap: (() -> Void)?

  private let containerView = UIView()
  private let imageAndTextContainerView = UIView()
  private let imageView = UIImageView()
  private let titleLabel = AttributedLabel(textStyle: .title2Bold)
  private let subtitleLabel = AttributedLabel(textStyle: .textRegular)
  private let refreshButton = StandardButton(type: .primary)

  // MARK: - Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Configure
 
  func configure(title: String, text: String?,
                 image: UIImage? = R.image.failureImage(),
                 refreshButtonTitle: String = R.string.common.refresh()) {
    titleLabel.text = title
    subtitleLabel.text = text
    imageView.image = image
    refreshButton.setTitle(refreshButtonTitle, for: .normal)
  }

  // MARK: - Actions

  @objc private func refreshButtonTapped(_ sender: UIButton) {
    onRefreshTap?()
  }

  // MARK: - Methods

  func startAnimating() {
    refreshButton.startAnimating()
  }

  func stopAnimating() {
    refreshButton.stopAnimating()
  }

  // MARK: - Setup

  private func setup() {
    backgroundColor = .white
    addContainerView()
    addImageAndTextContainerView()
    addImageView()
    addTitleLabel()
    addSubtitleLabel()
    addRefreshButton()
  }

  private func addContainerView() {
    addSubview(containerView)
    containerView.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(UIApplication.shared.statusBarFrame.height)
      make.leading.trailing.equalToSuperview()
    }
  }

  private func addImageAndTextContainerView() {
    containerView.addSubview(imageAndTextContainerView)
    imageAndTextContainerView.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.leading.trailing.equalToSuperview()
    }
  }

  private func addImageView() {
    imageAndTextContainerView.addSubview(imageView)
    imageView.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.centerX.equalToSuperview()
      make.size.equalTo(80)
    }
    imageView.contentMode = .scaleAspectFit
  }

  private func addTitleLabel() {
    imageAndTextContainerView.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { make in
      make.top.equalTo(imageView.snp.bottom).offset(32)
      make.trailing.leading.equalToSuperview().inset(20)
    }
    titleLabel.textAlignment = .center
    titleLabel.numberOfLines = 0
  }

  private func addSubtitleLabel() {
    imageAndTextContainerView.addSubview(subtitleLabel)
    subtitleLabel.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(16)
      make.trailing.leading.equalToSuperview().inset(20)
      make.bottom.equalToSuperview()
    }
    subtitleLabel.textAlignment = .center
    subtitleLabel.numberOfLines = 0
  }

  private func addRefreshButton() {
    addSubview(refreshButton)
    refreshButton.snp.makeConstraints { make in
      make.height.equalTo(56)
      make.leading.trailing.equalToSuperview().inset(20)
      make.bottom.equalToSuperview().inset(40)
      make.top.equalTo(containerView.snp.bottom)
    }
    refreshButton.setTitle(R.string.common.refresh(), for: .normal)
    refreshButton.addTarget(self, action: #selector(refreshButtonTapped(_:)), for: .touchUpInside)
  }
}
