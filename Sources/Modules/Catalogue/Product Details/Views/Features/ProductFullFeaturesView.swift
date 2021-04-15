//
//  ProductFullFeaturesView.swift
//  ForwardLeasing
//

import UIKit

class ProductFullFeaturesView: UIView, Configurable {
  // MARK: - Properties
  
  private let stackView = UIStackView()
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
  
  func configure(with viewModel: ProductFullFeaturesViewModel) {
    stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    stackView.addArrangedSubview(descriptionLabel)
    stackView.setCustomSpacing(16, after: descriptionLabel)
    
    descriptionLabel.text = viewModel.productDescription
    viewModel.secondaryFeatures.forEach { feature in
      stackView.addArrangedSubview(createFeatureRowView(title: feature.title,
                                                        content: feature.content))
    }
  }
  
  // MARK: - Setup
  
  private func setup() {
    setupStackView()
    setupDescriptionLabel()
  }
  
  private func setupStackView() {
    addSubview(stackView)
    stackView.axis = .vertical
    stackView.spacing = 14
    stackView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(20)
      make.top.equalToSuperview().inset(15)
      make.bottom.equalToSuperview().inset(32)
    }
  }
  
  private func setupDescriptionLabel() {
    descriptionLabel.numberOfLines = 0
    descriptionLabel.textColor = .base1
  }
  
  // MARK: - Private methods
  
  private func createFeatureRowView(title: String?, content: String?) -> UIView {
    let containerView = UIStackView()
    containerView.spacing = 15
    containerView.alignment = .top
    containerView.distribution = .fillEqually
    containerView.axis = .horizontal
    
    let leftLabel = AttributedLabel(textStyle: .textRegular)
    leftLabel.textColor = .shade70
    leftLabel.numberOfLines = 0
    leftLabel.text = title
    containerView.addArrangedSubview(leftLabel)
    
    let rightLabel = AttributedLabel(textStyle: .textRegular)
    rightLabel.textColor = .base1
    rightLabel.numberOfLines = 0
    rightLabel.text = content
    containerView.addArrangedSubview(rightLabel)
    
    return containerView
  }
}
