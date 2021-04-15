//
//  ProductDescriptionView.swift
//  ForwardLeasing
//

import UIKit

struct ProductDescriptionConfiguration {
  let title: String
  let color: UIColor
}

protocol ProductDescriptionViewModelProtocol: class {
  var nameTitle: String { get }
  var paymentTitle: String { get }
  var descriptions: [ProductDescriptionConfiguration] { get }
}

class ProductDescriptionView: UIView {
  // MARK: - Properties
  private let containerStackView = UIStackView()
  private let nameLabel = AttributedLabel(textStyle: .textBold)
  private let paymentLabel = AttributedLabel(textStyle: .title2Bold)
  private var descriptionLabels: [AttributedLabel] = []

  // MARK: - Init
  override init(frame: CGRect) {
    super.init(frame: frame)

    setup()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Configure
  func configure(with viewModel: ProductDescriptionViewModelProtocol) {
    nameLabel.text = viewModel.nameTitle
    paymentLabel.text = viewModel.paymentTitle
    nameLabel.isHidden = viewModel.nameTitle.isEmpty
    paymentLabel.isHidden = viewModel.paymentTitle.isEmpty
    descriptionLabels.forEach {
      containerStackView.removeArrangedSubview($0)
      $0.removeFromSuperview()
    }
    descriptionLabels.removeAll()
    viewModel.descriptions.forEach {
      let label = AttributedLabel(textStyle: .textRegular)
      label.numberOfLines = 0
      label.text = $0.title
      label.textColor = $0.color
      descriptionLabels.append(label)
      containerStackView.addArrangedSubview(label)
    }
  }

  // MARK: - Private methods
  private func setup() {
    setupContainerStackView()
    setupNameLabel()
    setupPaymentLabel()
  }

  private func setupContainerStackView() {
    addSubview(containerStackView)
    containerStackView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    containerStackView.axis = .vertical
    containerStackView.spacing = 10
  }

  private func setupNameLabel() {
    containerStackView.addArrangedSubview(nameLabel)
    nameLabel.numberOfLines = 0
    nameLabel.textColor = .base1
  }

  private func setupPaymentLabel() {
    containerStackView.addArrangedSubview(paymentLabel)
    paymentLabel.numberOfLines = 0
    paymentLabel.textColor = .base1
  }
}
