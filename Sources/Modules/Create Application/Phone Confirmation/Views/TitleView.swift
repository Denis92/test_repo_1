//
//  PersonalDataRegTitleView.swift
//  ForwardLeasing
//

import UIKit

class TitleView: UIView {
  // MARK: - Subviews
  private let titleLabel = AttributedLabel(textStyle: .textBold)
  
  // MARK: - Properties
  var title: String? {
    didSet {
      titleLabel.text = title
      titleLabel.sizeToFit()
    }
  }
  
  // MARK: - Init
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }
  
  // MARK: - Private
  private func setup() {
    setupTitleLabel()
  }
  
  private func setupTitleLabel() {
    addSubview(titleLabel)
    titleLabel.textColor = .base2
    titleLabel.numberOfLines = 2
    titleLabel.textAlignment = .center
    titleLabel.snp.makeConstraints { make in
      make.top.bottom.greaterThanOrEqualToSuperview()
      make.centerY.equalToSuperview()
      make.leading.trailing.equalToSuperview()
    }
  }
}
