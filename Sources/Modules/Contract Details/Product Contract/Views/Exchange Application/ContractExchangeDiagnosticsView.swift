//
//  ContractExchangeDiagnosticsView.swift
//  ForwardLeasing
//

import UIKit

private extension Constants {
  static let dotsCount = 3
}

class ContractExchangeDiagnosticsView: UIView {
  // MARK: - Properties
  
  private let dotsStackView = UIStackView()
  private let titleLabel = AttributedLabel(textStyle: .title2Bold)
  private let subtitleLabel = AttributedLabel(textStyle: .textRegular)
  
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
    setupDotsStackView()
    setupDots()
    setupTitleLabel()
    setupSubtitleLabel()
  }
  
  private func setupDotsStackView() {
    addSubview(dotsStackView)
    dotsStackView.axis = .horizontal
    dotsStackView.spacing = 15
    dotsStackView.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.centerX.equalToSuperview()
    }
  }
  
  private func setupDots() {
    for _ in 0..<Constants.dotsCount {
      let dotView = UIView()
      dotView.backgroundColor = .accent
      dotView.layer.cornerRadius = 6
      dotView.snp.makeConstraints { make in
        make.size.equalTo(12)
      }
      dotsStackView.addArrangedSubview(dotView)
    }
  }
  
  private func setupTitleLabel() {
    addSubview(titleLabel)
    titleLabel.numberOfLines = 0
    titleLabel.textAlignment = .center
    titleLabel.text = R.string.contractDetails.exchangeDiagnosticsTitle()
    titleLabel.snp.makeConstraints { make in
      make.top.equalTo(dotsStackView.snp.bottom).offset(32)
      make.leading.trailing.equalToSuperview()
    }
  }
  
  private func setupSubtitleLabel() {
    addSubview(subtitleLabel)
    subtitleLabel.numberOfLines = 0
    subtitleLabel.textAlignment = .center
    subtitleLabel.text = R.string.contractDetails.exchangeDiagnosticsSubtitle()
    subtitleLabel.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(16)
      make.leading.trailing.bottom.equalToSuperview()
    }
  }
}
