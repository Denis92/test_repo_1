//
//  SendingApplicationView.swift
//  ForwardLeasing
//

import UIKit

class SendingApplicationView: UIView {
  // MARK: - Subviews
  private let containerView = UIView()
  private let textLabel = AttributedLabel(textStyle: .title2Bold)
  private let activityIndicator = ActivityIndicatorView()
  
  // MARK: - Init
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  private func setup() {
    setupContainerView()
    setupActivityIndicator()
    setupLabel()
  }
  
  private func setupContainerView() {
    addSubview(containerView)
    containerView.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.leading.trailing.equalToSuperview()
    }
  }
  
  private func setupActivityIndicator() {
    containerView.addSubview(activityIndicator)
    activityIndicator.isAnimating = true
    activityIndicator.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.centerX.equalToSuperview()
    }
  }
  
  private func setupLabel() {
    containerView.addSubview(textLabel)
    textLabel.text = R.string.sendingApplication.sendingViewTitle()
    textLabel.textAlignment = .center
    textLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(activityIndicator.snp.bottom).offset(32)
      make.bottom.equalToSuperview()
    }
  }
}
