//
//  UserDataItemView.swift
//  ForwardLeasing
//

import UIKit

protocol UserDataItemViewModelProtocol {
  var title: String? { get }
  var value: String? { get }
  var style: UserDataItemViewStyle { get }
}

enum UserDataItemViewStyle {
  case textField
  case normal
  case bold
  
  var titleStyle: TextStyle {
    switch self {
    case .textField:
      return .footnoteRegular
    case .normal, .bold:
      return .textRegular
    }
  }
  
  var valueStyle: TextStyle {
    switch self {
    case .textField, .normal:
      return .textRegular
    case .bold:
      return .textBold
    }
  }
}

class UserDataItemView: UIView, Configurable {
  // MARK: - Outlets
  private let titleLabel = AttributedLabel(textStyle: .footnoteRegular)
  private let valueLabel = AttributedLabel(textStyle: .textRegular)

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
  
  func configure(with viewModel: UserDataItemViewModelProtocol) {
    titleLabel.text = viewModel.title
    valueLabel.text = viewModel.value
    titleLabel.change(textStyle: viewModel.style.titleStyle)
    valueLabel.change(textStyle: viewModel.style.valueStyle)
  }
  
  // MARK: - Private Methods
  
  private func setup() {
    setupTitleLabel()
    setupValueLabel()
  }
  
  private func setupTitleLabel() {
    addSubview(titleLabel)
    titleLabel.textColor = .shade70
    titleLabel.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
    }
  }
  
  private func setupValueLabel() {
    addSubview(valueLabel)
    valueLabel.textColor = .base1
    valueLabel.numberOfLines = 0
    valueLabel.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(2)
      make.leading.bottom.trailing.equalToSuperview()
    }
  }
}
