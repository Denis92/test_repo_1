//
//  NavigationBarTitleView.swift
//  ForwardLeasing
//

import UIKit

class NavigationBarTitleView: UIView {
  // MARK: - Private properties
  
  private let titleLabel = AttributedLabel(textStyle: .title2Semibold)
  private let leftStackView = UIStackView()
  private let rightStackView = UIStackView()
  
  // MARK: - Init
  
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Public methods
  
  func setTitle(_ title: String?) {
    titleLabel.text = title
  }
  
  func setLeftViews(_ views: [UIView]) {
    views.forEach { leftStackView.addArrangedSubview($0) }
  }
  
  func setRightViews(_ views: [UIView]) {
    views.forEach { rightStackView.addArrangedSubview($0) }
  }
  
  // MARK: - Setup
  
  private func setup() {
    setupContainer()
    setupLeftStackView()
    setupRightStackView()
    setupTitle()
  }
  
  private func setupContainer() {
    snp.makeConstraints { make in
      make.height.equalTo(44)
    }
  }
  
  private func setupLeftStackView() {
    addSubview(leftStackView)
    leftStackView.axis = .horizontal
    leftStackView.alignment = .center
    leftStackView.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(10)
      make.top.equalToSuperview()
      make.bottom.equalToSuperview().inset(12)
    }
  }
  
  private func setupRightStackView() {
    addSubview(rightStackView)
    rightStackView.axis = .horizontal
    rightStackView.alignment = .center
    rightStackView.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(10)
      make.top.equalToSuperview()
      make.bottom.equalToSuperview().inset(12)
    }
  }
  
  private func setupTitle() {
    addSubview(titleLabel)
    
    titleLabel.numberOfLines = 2
    titleLabel.textAlignment = .center
    titleLabel.textColor = .base2
    titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    titleLabel.adjustsFontSizeToFitWidth = true
    
    titleLabel.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.leading.greaterThanOrEqualTo(leftStackView.snp.trailing)
      make.trailing.lessThanOrEqualTo(rightStackView.snp.leading)
    }
  }
}
