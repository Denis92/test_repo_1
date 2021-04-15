//
//  ProductDeliveryView.swift
//  ForwardLeasing
//

import UIKit

protocol ProductDeliveryViewModelProtocol {
  var currentStep: Int { get }
  var stepsCount: Int { get }
  var description: String { get }
  var descriptionColor: UIColor { get }
}

class ProductDeliveryView: UIView {
  // MARK: - Properties
  private let progressStackView = UIStackView()
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
  func configure(with viewModel: ProductDeliveryViewModelProtocol) {
    progressStackView.arrangedSubviews.forEach {
      $0.removeFromSuperview()
    }
    (1...viewModel.stepsCount).forEach {
      let view = UIView()
      view.makeRoundedCorners(radius: 3)
      view.backgroundColor = $0 <= viewModel.currentStep ? .accent2 : .shade40
      progressStackView.addArrangedSubview(view)
    }
    descriptionLabel.text = viewModel.description
    descriptionLabel.textColor = viewModel.descriptionColor
  }
  
  // MARK: - Private Methods
  private func setup() {
    setupProgressStackView()
    setupDescriptionLabel()
  }
  
  private func setupProgressStackView() {
    addSubview(progressStackView)
    progressStackView.snp.makeConstraints { make in
      make.leading.top.trailing.equalToSuperview()
      make.height.equalTo(5)
    }
    progressStackView.axis = .horizontal
    progressStackView.spacing = 5
    progressStackView.distribution = .fillEqually
  }
  
  private func setupDescriptionLabel() {
    addSubview(descriptionLabel)
    descriptionLabel.snp.makeConstraints { make in
      make.leading.bottom.trailing.equalToSuperview()
      make.top.equalTo(progressStackView.snp.bottom).offset(10)
    }
    descriptionLabel.numberOfLines = 0
  }
}

// MARK: - StackViewItemView
extension ProductDeliveryView: StackViewItemView {
  func configure(with viewModel: StackViewItemViewModel) {
    guard let viewModel = viewModel as? ProductDeliveryViewModelProtocol else {
      return
    }
    configure(with: viewModel)
  }
}
