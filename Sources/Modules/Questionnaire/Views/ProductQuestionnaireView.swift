//
//  QuesttionaireView.swift
//  ForwardLeasing
//

import UIKit

protocol ProductQuestionnaireViewModelProtocol {
  var items: [QuestionnaireItemViewModel] { get }
}

class ProductQuestionnaireView: UIView, Configurable {
  // MARK: - Subviews
  private let titleLabel = AttributedLabel(textStyle: .title2Bold)
  private let stackView = UIStackView()
  
  // MARK: - Properties
  
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
  func configure(with viewModel: ProductQuestionnaireViewModelProtocol) {
    updateItems(with: viewModel.items)
  }
  
  // MARK: - Private Methods
  private func setup() {
    setupTitleLabel()
    setupStackView()
  }
  
  private func setupTitleLabel() {
    addSubview(titleLabel)
    titleLabel.textColor = .base1
    titleLabel.numberOfLines = 0
    titleLabel.text = R.string.questionnaire.gradeTitle()
    titleLabel.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.leading.trailing.equalToSuperview()
    }
  }
  
  private func setupStackView() {
    addSubview(stackView)
    stackView.axis = .vertical
    stackView.spacing = 32
    stackView.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(24)
      make.leading.trailing.bottom.equalToSuperview()
    }
  }
  
  private func updateItems(with viewModels: [QuestionnaireItemViewModel]) {
    stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    viewModels.forEach {
      let view = QuestionnaireItemView()
      view.configure(with: $0)
      stackView.addArrangedSubview(view)
    }
  }
}

// MARK: - Actions
private extension ProductQuestionnaireView {}
