//
//  ExchangeReturnTitleView.swift
//  ForwardLeasing
//

import UIKit

protocol ExchangeReturnTitleViewModelProtocol {
  var title: String? { get }
}

class ExchangeReturnTitleView: UIView, Configurable {
  // MARK: - Properties
  private let titleLabel = AttributedLabel(textStyle: .title2Bold)

  // MARK: - Init
  override init(frame: CGRect) {
    super.init(frame: frame)

    setup()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Configure
  func configure(with viewModel: ExchangeReturnTitleViewModelProtocol) {
    titleLabel.text = viewModel.title
  }

  // MARK: - Private methods
  private func setup() {
    setupTitleLabel()
  }

  private func setupTitleLabel() {
    addSubview(titleLabel)
    titleLabel.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    titleLabel.numberOfLines = 0
    titleLabel.textColor = .base1
  }

}
