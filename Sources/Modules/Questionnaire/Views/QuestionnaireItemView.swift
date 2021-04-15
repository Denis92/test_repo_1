//
//  QuestionnaireItemView.swift
//  ForwardLeasing
//

import UIKit

protocol QuestionnaireItemViewModelProtocol {
  var title: String? { get }
  var description: String? { get }
  var answers: [ProductPropertyPickerItemViewModel] { get }
  var onDidSelectAnswerAtIndex: ((Int) -> Void)? { get }
}

class QuestionnaireItemView: UIView, Configurable {
  // MARK: - Subviews
  private let titleLabel = AttributedLabel(textStyle: .textBold)
  private let descriptionLabel = AttributedLabel(textStyle: .textRegular)
  private let pickerContainer = UIStackView()
  
  // MARK: - Properties
  private var onDidSelectAnswerAtIndex: ((Int) -> Void)?
  
  // MARK: - Init
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }
  
  // MARK: - Public Methods
  func configure(with viewModel: QuestionnaireItemViewModelProtocol) {
    titleLabel.text = viewModel.title
    descriptionLabel.text = viewModel.description
    onDidSelectAnswerAtIndex = viewModel.onDidSelectAnswerAtIndex
    updatePickerContainer(with: viewModel.answers)
  }
  
  // MARK: - Private Methods
  private func updatePickerContainer(with answers: [ProductPropertyPickerItemViewModel]) {
    pickerContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }
    answers.forEach {
      let view = ProductPropertyPickerItemView()
      view.configure(with: $0)
      pickerContainer.addArrangedSubview(view)
    }
  }
  
  private func setup() {
    setupTitleLabel()
    setupDescriptionLabel()
    setupPickerContainer()
  }
  
  private func setupTitleLabel() {
    addSubview(titleLabel)
    titleLabel.textColor = .base1
    titleLabel.numberOfLines = 0
    titleLabel.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
    }
  }
  
  private func setupDescriptionLabel() {
    addSubview(descriptionLabel)
    descriptionLabel.numberOfLines = 0
    descriptionLabel.textColor = .shade70
    descriptionLabel.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(8)
      make.leading.trailing.equalToSuperview()
    }
  }
  
  private func setupPickerContainer() {
    addSubview(pickerContainer)
    pickerContainer.spacing = 16
    pickerContainer.snp.makeConstraints { make in
      make.top.equalTo(descriptionLabel.snp.bottom).offset(8)
      make.leading.bottom.equalToSuperview()
    }
  }
}
