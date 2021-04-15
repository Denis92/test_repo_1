//
//  CurrentApplicationsItemView.swift
//  ForwardLeasing
//

import UIKit

class CurrentApplicationsItemView: UIView, Configurable {
  // MARK: - Properties
  
  private let containerStackView = UIStackView()
  private let descriptionStackView = UIStackView()
  private let titleLabel = AttributedLabel(textStyle: .textBold)
  private let priceLabel = AttributedLabel(textStyle: .title2Bold)
  private let imageView = UIImageView()
  private let continueButton = StandardButton(type: .primary)
  
  private var viewModel: CurrentApplicationsItemViewModel?
  
  // MARK: - Init
  
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure
  
  func configure(with viewModel: CurrentApplicationsItemViewModel) {
    self.viewModel = viewModel
    titleLabel.text = viewModel.title
    priceLabel.text = viewModel.price
    imageView.setImage(with: viewModel.imageURL)
    continueButton.setTitle(viewModel.buttonConfiguration.title, for: .normal)
    continueButton.updateType(viewModel.buttonConfiguration.type)
  }
  
  // MARK: - Actions
  
  @objc private func didTapContinueButton() {
    viewModel?.continueApplication()
  }
  
  // MARK: - Setup
  
  private func setup() {
    setupContainerStackView()
    setupContinueButton()
    setupDescriptionStackVeiew()
    setupTitleLabel()
    setupPriceLabel()
    setupImageView()
  }
  
  private func setupContainerStackView() {
    addSubview(containerStackView)
    
    containerStackView.axis = .horizontal
    containerStackView.spacing = 18
    containerStackView.alignment = .center
    
    containerStackView.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }
  
  private func setupContinueButton() {
    addSubview(continueButton)
  
    continueButton.addTarget(self, action: #selector(didTapContinueButton), for: .touchUpInside)
    
    continueButton.snp.makeConstraints { make in
      make.top.equalTo(containerStackView.snp.bottom).offset(20)
      make.leading.trailing.equalToSuperview().inset(20)
      make.bottom.equalToSuperview().inset(24)
    }
  }
  
  private func setupDescriptionStackVeiew() {
    containerStackView.addArrangedSubview(descriptionStackView)
    
    descriptionStackView.axis = .vertical
    descriptionStackView.spacing = 10
  }
  
  private func setupTitleLabel() {
    descriptionStackView.addArrangedSubview(titleLabel)
    
    titleLabel.numberOfLines = 0
    titleLabel.textColor = .base1
  }
  
  private func setupPriceLabel() {
    descriptionStackView.addArrangedSubview(priceLabel)
    
    priceLabel.numberOfLines = 0
    priceLabel.textColor = .base1
  }
  
  private func setupImageView() {
    containerStackView.addArrangedSubview(imageView)
    imageView.contentMode = .scaleAspectFit
    imageView.snp.makeConstraints { make in
      make.size.equalTo(122)
    }
  }
}
