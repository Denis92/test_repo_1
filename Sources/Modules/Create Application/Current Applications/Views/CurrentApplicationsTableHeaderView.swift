//
//  CurrentApplicationsTableHeaderView.swift
//  ForwardLeasing
//

import UIKit

class CurrentApplicationsTableHeaderView: UIView, Configurable {
  // MARK: - Properties
  
  private let descriptionLabel = AttributedLabel(textStyle: .title3Semibold)
  
  // MARK: - Init
  
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure
  
  func configure(with viewModel: CurrentApplicationsTableHeaderViewModel) {
    descriptionLabel.text = viewModel.descriptionText
  }
  
  // MARK: - Setup
  
  private func setup() {
    addSubview(descriptionLabel)
    
    descriptionLabel.numberOfLines = 0
    descriptionLabel.textColor = .accent
    
    descriptionLabel.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(20)
      make.top.equalToSuperview()
      make.bottom.equalToSuperview().inset(16)
    }
  }
}
