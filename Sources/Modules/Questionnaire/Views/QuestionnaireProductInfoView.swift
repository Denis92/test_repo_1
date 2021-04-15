//
//  QuestionnaireProductInfoView.swift
//  ForwardLeasing
//

import UIKit

enum QuestionaireProductInfoViewType {
  case exchange(firstItem: QuestionnaireProductInfoItemViewModel,
                secondItem: QuestionnaireProductInfoItemViewModel)
  case `return`(item: QuestionnaireProductInfoItemViewModel)
}

class QuestionnaireProductInfoView: UIView, Configurable {
  // MARK: - Subviews
  private let stackView = UIStackView()
  private let separator = UIView()
  private let exchangeIcon = UIImageView()
  private let firstProductInfoView = QuestionnaireProductInfoItemView()
  private let secondProductInfoView = QuestionnaireProductInfoItemView()
  
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
  func configure(with type: QuestionaireProductInfoViewType) {
    switch type {
    case .exchange(let firstItemViewModel, let secondItemViewModel):
      configureExchangeItems(firstItemViewModel: firstItemViewModel,
                             secondItemViewModel: secondItemViewModel)
    case .return(let itemViewModel):
      configureReturnItem(itemViewModel: itemViewModel)
    }
  }
  
  // MARK: - Private Methods
  private func setup() {
    setupItems()
    setupExchangeIcon()
  }
  
  private func configureExchangeItems(firstItemViewModel: QuestionnaireProductInfoItemViewModel,
                                      secondItemViewModel: QuestionnaireProductInfoItemViewModel) {
    firstProductInfoView.configure(with: firstItemViewModel)
    secondProductInfoView.configure(with: secondItemViewModel)
    setupExchangeState(true)
  }
  
  private func configureReturnItem(itemViewModel: QuestionnaireProductInfoItemViewModel) {
    firstProductInfoView.configure(with: itemViewModel)
    setupExchangeState(false)
  }
  
  private func setupExchangeState(_ isExchange: Bool) {
    secondProductInfoView.isHidden = !isExchange
    separator.isHidden = !isExchange
    exchangeIcon.isHidden = !isExchange
  }
  
  private func setupItems() {
    addSubview(stackView)
    stackView.axis = .vertical
    stackView.snp.makeConstraints { make in
      make.leading.top.bottom.equalToSuperview()
    }
    
    stackView.addArrangedSubview(firstProductInfoView)
    
    let separator = UIView()
    separator.backgroundColor = .shade30
    separator.snp.makeConstraints { make in
      make.height.equalTo(1)
    }
    stackView.addArrangedSubview(separator)
    
    stackView.addArrangedSubview(secondProductInfoView)
  }
  
  private func setupExchangeIcon() {
    addSubview(exchangeIcon)
    exchangeIcon.contentMode = .scaleAspectFit
    exchangeIcon.image = R.image.exchangeIcon()
    exchangeIcon.snp.makeConstraints { make in
      make.leading.equalTo(stackView.snp.trailing)
      make.centerY.equalTo(stackView)
      make.size.equalTo(24)
      make.trailing.equalToSuperview()
    }
  }
}
