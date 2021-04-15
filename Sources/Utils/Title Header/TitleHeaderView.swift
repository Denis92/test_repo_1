//
//  TitleHeaderView.swift
//  ForwardLeasing
//

import UIKit
import SnapKit

typealias TitleHeader = CommonContainerHeaderFooterView<TitleHeaderView>

class TitleHeaderView: UIView, Configurable {
  // MARK: - Subviews
  private let titleLabel = AttributedLabel(textStyle: .title2Bold)
  
  // MARK: - Properties
  private var topOffsetConstraint: Constraint?
  
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
  func configure(with viewModel: TitleHeaderViewModel) {
    titleLabel.text = viewModel.title
    if let topOffset = viewModel.topOffset {
      topOffsetConstraint?.update(inset: topOffset)
    }
  }
  
  // MARK: - Private Methods
  private func setup() {
    addSubview(titleLabel)
    titleLabel.textColor = .base1
    titleLabel.numberOfLines = 0
    titleLabel.snp.makeConstraints { make in
      topOffsetConstraint = make.top.equalToSuperview().constraint
      make.leading.trailing.equalToSuperview().inset(20)
      make.bottom.equalToSuperview().inset(12)
    }
  }
}
