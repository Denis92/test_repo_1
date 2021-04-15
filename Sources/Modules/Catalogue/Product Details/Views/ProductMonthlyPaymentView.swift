//
//  ProductMonthlyPaymentView.swift
//  ForwardLeasing
//

import UIKit

class ProductMonthlyPaymentView: UIView {
  // MARK: - Properties
  
  private let stackView = UIStackView()
  private let monthlySumLabel = AttributedLabel(textStyle: .title1Bold)
  private let monthlySumHintLabel = AttributedLabel(textStyle: .textRegular)
  private let dividerView = UIView()
  private let equationLabel = AttributedLabel(textStyle: .title2Bold)
  private let propertiesStackView = UIStackView()
  
  // MARK: - Init
  
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure
  
  func configure(with viewModel: ProductMonthlyPaymentViewModel) {
    updatePaymnentInfo(viewModel: viewModel)
    viewModel.onDidUpdate = { [weak self, weak viewModel] in
      guard let viewModel = viewModel else { return }
      self?.updatePaymnentInfo(viewModel: viewModel)
    }
  }
  
  // MARK: - Private methods
  
  private func updatePaymnentInfo(viewModel: ProductMonthlyPaymentViewModel) {
    monthlySumLabel.text = viewModel.monthlySumText
    equationLabel.text = viewModel.equationText
    
    propertiesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    viewModel.properties.forEach { property in
      let item = createPropertyRow(leftText: property.value, rightText: property.description)
      propertiesStackView.addArrangedSubview(item)
    }
  }
  
  // MARK: - Setup
  
  private func setup() {
    setupConatiner()
    setupMonthlySumLabel()
    setupMonthlySumHintLabel()
    setupDividerView()
    setupEquationLabel()
    setupPropertiesStackView()
  }
  
  private func setupConatiner() {
    addSubview(stackView)
    stackView.axis = .vertical
    stackView.snp.makeConstraints { make in
      make.top.bottom.equalToSuperview()
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }
  
  private func setupMonthlySumLabel() {
    stackView.addArrangedSubview(monthlySumLabel)
    monthlySumLabel.numberOfLines = 0
    monthlySumLabel.textColor = .accent
    stackView.setCustomSpacing(4, after: monthlySumLabel)
  }
  
  private func setupMonthlySumHintLabel() {
    stackView.addArrangedSubview(monthlySumHintLabel)
    monthlySumHintLabel.numberOfLines = 0
    monthlySumHintLabel.textColor = .shade70
    stackView.setCustomSpacing(10, after: monthlySumHintLabel)
    monthlySumHintLabel.text = R.string.productDetails.monthlySumHintLabelText()
  }
  
  private func setupDividerView() {
    stackView.addArrangedSubview(dividerView)
    dividerView.backgroundColor = .shade40
    dividerView.snp.makeConstraints { make in
      make.height.equalTo(1)
    }
    stackView.setCustomSpacing(16, after: dividerView)
  }
  
  private func setupEquationLabel() {
    stackView.addArrangedSubview(equationLabel)
    equationLabel.textColor = .accent
    equationLabel.numberOfLines = 0
    stackView.setCustomSpacing(16, after: equationLabel)
  }
  
  private func setupPropertiesStackView() {
    stackView.addArrangedSubview(propertiesStackView)
    propertiesStackView.spacing = 10
    propertiesStackView.axis = .vertical
  }
  
  // MARK: - Private methods
  
  private func createPropertyRow(leftText: String?, rightText: String?) -> UIView {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 30
    
    let leftLabel = AttributedLabel(textStyle: .textRegular)
    leftLabel.textColor = .base1
    leftLabel.numberOfLines = 0
    leftLabel.text = leftText
    stackView.addArrangedSubview(leftLabel)
    
    leftLabel.snp.makeConstraints { make in
      make.width.equalTo(80)
    }
    
    let rightLabel = AttributedLabel(textStyle: .textRegular)
    rightLabel.textColor = .base1
    rightLabel.numberOfLines = 0
    rightLabel.text = rightText
    stackView.addArrangedSubview(rightLabel)
    
    return stackView
  }
}

extension ProductMonthlyPaymentView: Configurable {
  typealias ViewModel = ProductMonthlyPaymentViewModel
}
