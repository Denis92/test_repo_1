//
//  AboutProductView.swift
//  ForwardLeasing
//

import UIKit

typealias AboutProductCell = CommonContainerTableViewCell<AboutProductView>

class AboutProductView: UIView, Configurable {
  // MARK: - Properties
  
  private let titleLabel = AttributedLabel(textStyle: .title2Bold)
  private let descriptionLabel = AttributedLabel(textStyle: .textRegular)
  
  // MARK: - Init
  
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure
  
  func configure(with viewModel: AboutProductViewModel) {
    descriptionLabel.text = viewModel.description
  }
  
  // MARK: - Setup
  
  private func setup() {
    setupTitleLabel()
    setupDescriptionLabel()
  }
  
  private func setupTitleLabel() {
    addSubview(titleLabel)
    titleLabel.numberOfLines = 0
    titleLabel.text = R.string.contractDetails.aboutProductTitle()
    titleLabel.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }
  
  private func setupDescriptionLabel() {
    addSubview(descriptionLabel)
    descriptionLabel.numberOfLines = 0
    descriptionLabel.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(16)
      make.leading.trailing.equalToSuperview().inset(20)
      make.bottom.equalToSuperview().inset(40)
    }
  }
}
