//
//  ContractInfoItemView.swift
//  ForwardLeasing
//

import UIKit

class ContractInfoItemView: UIView, Configurable {
  // MARK: - Properties
  
  private let containerStackView = UIStackView()
  private let imageView = UIImageView()
  private let contentStackView = UIStackView()
  private let titleLabel = AttributedLabel(textStyle: .textBold)
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
  
  func configure(with viewModel: ContractInfoItemViewModel) {
    imageView.image = viewModel.image ?? R.image.contractInfoDefaultIcon()
    titleLabel.text = viewModel.title
    descriptionLabel.text = viewModel.description
  }
  
  // MARK: - Setup
  
  private func setup() {
    setupContainerStackView()
    setupImageView()
    setupContentStackView()
    setupTitleLabel()
    setupDescriptionLabel()
  }
  
  private func setupContainerStackView() {
    addSubview(containerStackView)
    containerStackView.axis = .horizontal
    containerStackView.spacing = 16
    containerStackView.alignment = .top
    containerStackView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  private func setupImageView() {
    containerStackView.addArrangedSubview(imageView)
    imageView.contentMode = .scaleAspectFit
    imageView.snp.makeConstraints { make in
      make.width.equalTo(25)
      make.height.equalTo(47)
    }
  }
  
  private func setupContentStackView() {
    containerStackView.addArrangedSubview(contentStackView)
    contentStackView.axis = .vertical
    contentStackView.spacing = 4
  }
  
  private func setupTitleLabel() {
    contentStackView.addArrangedSubview(titleLabel)
    titleLabel.textColor = .base1
    titleLabel.numberOfLines = 0
  }
  
  private func setupDescriptionLabel() {
    contentStackView.addArrangedSubview(descriptionLabel)
    descriptionLabel.textColor = .shade70
    descriptionLabel.numberOfLines = 0
  }
}
