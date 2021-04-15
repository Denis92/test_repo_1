//
//  ProductStatusDescriptionView.swift
//  ForwardLeasing
//

import UIKit

protocol ProductStatusDescriptionViewModelProtocol {
  var productDescriptionConfiguration: ProductDescriptionConfiguration { get }
}

class ProductStatusDescriptionView: UIView {
  // MARK: - Properties
  private let containerStackView = UIStackView()
  private let descriptionLabel = AttributedLabel(textStyle: .textRegular)

  // MARK: - Init
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure
  func configure(with viewModel: ProductStatusDescriptionViewModelProtocol) {
    descriptionLabel.text = viewModel.productDescriptionConfiguration.title
    descriptionLabel.isHidden = viewModel.productDescriptionConfiguration.title.isEmpty
    descriptionLabel.textColor = viewModel.productDescriptionConfiguration.color
  }
  
  // MARK: - Private Methods
  private func setup() {
    setupContainerStackView()
    setupDescriptionLabel()
  }
  
  private func setupContainerStackView() {
    addSubview(containerStackView)
    containerStackView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    containerStackView.axis = .vertical
  }

  private func setupDescriptionLabel() {
    containerStackView.addArrangedSubview(descriptionLabel)
    descriptionLabel.numberOfLines = 0
  }
}

// MARK: - StackViewItemView
extension ProductStatusDescriptionView: StackViewItemView {
  func configure(with viewModel: StackViewItemViewModel) {
    guard let viewModel = viewModel as? ProductStatusDescriptionViewModelProtocol else {
      return
    }
    configure(with: viewModel)
  }
}
