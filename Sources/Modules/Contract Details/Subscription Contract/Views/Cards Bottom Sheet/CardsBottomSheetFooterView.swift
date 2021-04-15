//
//  CardsBottomSheetFooterView.swift
//  ForwardLeasing
//

import UIKit

protocol CardsBottomSheetFooterViewModelProtocol {
  func didTapSelectCardButton(saveCard: Bool)
}

class CardsBottomSheetFooterView: UIView {
  private let selectButton = StandardButton(type: .primary)
  private let saveCardDataCheckbox = Checkbox(type: .rounded)
  private let checkboxTitleLabel = AttributedLabel(textStyle: .textRegular)
  
  private var viewModel: CardsBottomSheetFooterViewModelProtocol
  
  init(viewModel: CardsBottomSheetFooterViewModelProtocol) {
    self.viewModel = viewModel
    super.init(frame: CGRect(x: 0, y: 0, width: UIView.noIntrinsicMetric,
                             height: 128))
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    setupSaveCardDataCheckbox()
    setupCheckboxTitleLabel()
    setupSelectButton()
  }
  
  private func setupSaveCardDataCheckbox() {
    addSubview(saveCardDataCheckbox)
    saveCardDataCheckbox.isSelected = true
    saveCardDataCheckbox.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(6)
      make.leading.equalToSuperview().inset(10)
    }
  }
  
  private func setupCheckboxTitleLabel() {
    addSubview(checkboxTitleLabel)
    checkboxTitleLabel.text = R.string.subscriptionDetails.saveCardDataCheckboxTitle()
    checkboxTitleLabel.snp.makeConstraints { make in
      make.leading.equalTo(saveCardDataCheckbox.snp.trailing).offset(4)
      make.centerY.equalTo(saveCardDataCheckbox)
    }
  }
  
  private func setupSelectButton() {
    addSubview(selectButton)
    selectButton.setTitle(R.string.subscriptionDetails.selectButtonTitle(), for: .normal)
    selectButton.actionHandler(controlEvents: .touchUpInside) { [weak self] in
      guard let self = self else { return }
      self.viewModel.didTapSelectCardButton(saveCard: self.saveCardDataCheckbox.isSelected)
    }
    selectButton.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(20)
      make.bottom.equalToSuperview()
    }
  }
}
