//
//  AcceptedView.swift
//  ForwardLeasing
//

import UIKit

class AcceptedView: UIView {
  // MARK: - Subviews
  private let containerView = UIView()
  private let subContainerView = UIView()
  private let acceptedImageView = UIImageView()
  private let titleLabel = AttributedLabel(textStyle: .title2Bold)
  private let finishButton = StandardButton(type: .primary)
  
  var onDidTapFinishButton: (() -> Void)?
  
  // MARK: - Init
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Public methods
  
  func startAnimatingButton() {
    finishButton.startAnimating()
  }
  
  func stopAnimatingButton() {
    finishButton.stopAnimating()
  }
  
  // MARK: - Setup
  private func setup() {
    setupNextButton()
    setupContainerView()
    setupImageView()
    setupTitleLabel()
    setupSubContainerView()
  }
  
  private func setupNextButton() {
    addSubview(finishButton)
    finishButton.addTarget(self, action: #selector(didTapFinish), for: .touchUpInside)
    finishButton.setTitle(R.string.sendingApplication.acceptedViewButtonNext(), for: .normal)
    finishButton.makeRoundedCorners(radius: 30)
    finishButton.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(20)
      make.bottom.equalToSuperview().offset(-40)
      make.height.equalTo(56)
    }
  }
  
  private func setupContainerView() {
    addSubview(containerView)
    containerView.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(UIApplication.shared.statusBarFrame.height)
      make.leading.trailing.equalToSuperview()
      make.bottom.equalTo(finishButton.snp.top)
    }
  }
  
  private func setupImageView() {
    containerView.addSubview(subContainerView)
    
    subContainerView.addSubview(acceptedImageView)
    acceptedImageView.image = R.image.accept()
    acceptedImageView.contentMode = .scaleAspectFit
    acceptedImageView.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
    }
  }
  
  private func setupTitleLabel() {
    subContainerView.addSubview(titleLabel)
    titleLabel.text = R.string.sendingApplication.acceptedViewTitle()
    titleLabel.textAlignment = .center
    titleLabel.snp.makeConstraints { make in
      make.leading.trailing.bottom.equalToSuperview()
      make.top.equalTo(acceptedImageView.snp.bottom).offset(32)
    }
  }
  
  private func setupSubContainerView() {
    subContainerView.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }
  
  @objc private func didTapFinish() {
    onDidTapFinishButton?()
  }
}
