//
//  PlaceholderView.swift
//  ForwardLeasing
//

import UIKit

class PlaceholderView: UIView {
  // MARK: - Subviews

  private let containerView = UIView()
  private let titleLabel = AttributedLabel(textStyle: .title2Bold)
  private let subtitleLabel = AttributedLabel(textStyle: .textRegular)

  // MARK: - Init

  init() {
    super.init(frame: .zero)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }

  // MARK: - Configure

  func configure(title: String, text: String) {
    titleLabel.text = title
    subtitleLabel.text = text
  }

  // MARK: - Setup

  private func setup() {
    isUserInteractionEnabled = false
    addContainerView()
    addTitleLabel()
    addSubtitleLabel()
  }

  private func addContainerView() {
    addSubview(containerView)
    containerView.backgroundColor = .base2
    containerView.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.leading.trailing.equalToSuperview().inset(55)
    }
  }

  private func addTitleLabel() {
    containerView.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
    }
    titleLabel.textAlignment = .center
    titleLabel.numberOfLines = 0
  }

  private func addSubtitleLabel() {
    containerView.addSubview(subtitleLabel)
    subtitleLabel.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(8)
      make.bottom.leading.trailing.equalToSuperview()
    }
    subtitleLabel.textAlignment = .center
    subtitleLabel.numberOfLines = 0
  }
}
