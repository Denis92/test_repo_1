//
//  CatalogueListHeaderView.swift
//  ForwardLeasing
//

import UIKit

class CatalogueListHeaderView: UIView, Configurable {
  private let titleLabel = AttributedLabel(textStyle: .title1Bold)

  // MARK: - Init

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Configure

  func configure(with viewModel: CatalogueListHeaderViewModel) {
    titleLabel.text = viewModel.title
  }

  // MARK: - Setup

  private func setup() {
    addSubview(titleLabel)
    titleLabel.snp.makeConstraints { make in
      make.top.bottom.equalToSuperview()
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }
}
