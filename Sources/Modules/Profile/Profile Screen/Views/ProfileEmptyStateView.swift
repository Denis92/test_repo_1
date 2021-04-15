//
//  ProfileEmptyStateView.swift
//  ForwardLeasing
//

import UIKit

typealias ProfileEmptyStateCell = CommonContainerTableViewCell<ProfileEmptyStateView>

class ProfileEmptyStateView: UIView, Configurable {
  // MARK: - Properties
  
  private let titleLabel = AttributedLabel(textStyle: .textRegular)
  
  // MARK: - Init
  
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure
  
  func configure(with viewModel: ProfileEmptyStateViewModel) {
    titleLabel.text = viewModel.title
  }
  
  // MARK: - Setup
  
  private func setup() {
    addSubview(titleLabel)
    titleLabel.numberOfLines = 0
    titleLabel.textAlignment = .center
    titleLabel.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(24)
      make.bottom.equalToSuperview()
      make.leading.trailing.equalToSuperview().inset(32)
    }
  }
}
