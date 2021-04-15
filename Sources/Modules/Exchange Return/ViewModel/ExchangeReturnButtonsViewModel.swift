//
//  ExchangeReturnButtonsViewModel.swift
//  ForwardLeasing
//

import Foundation

protocol ExchangeReturnButtonsViewModelDelegate: class {
  func exchangeReturnButtonsViewModelDidTapPrimaryButton(_ viewModel: ExchangeReturnButtonsViewModel)
  func exchangeReturnButtonsViewModelDidTapCancelContractButton(_ viewModel: ExchangeReturnButtonsViewModel)
}

class ExchangeReturnButtonsViewModel {
  weak var delegate: ExchangeReturnButtonsViewModelDelegate?
  
  var onDidStartRequest: (() -> Void)?
  var onDidFinishRequest: (() -> Void)?
  
  var primaryButtonTitle: String? {
    return buttonsTitles.primaryButtonTitle(exchangeInfoState: exchangeInfoState)
  }

  var cancelButtonTitle: String? {
    return buttonsTitles.cancelButtonTitle
  }

  var shouldHidePrimaryButton: Bool {
    return exchangeInfoState == .awatingDiagnostics
  }
  
  var shouldHideCancelButton: Bool {
    return exchangeInfoState == .complete
  }
  
  private let exchangeInfoState: ExchangeReturnState
  private let buttonsTitles: ExchangeReturnButtonsTitles
  
  init(exchangeInfoState: ExchangeReturnState,
       buttonsTitles: ExchangeReturnButtonsTitles) {
    self.exchangeInfoState = exchangeInfoState
    self.buttonsTitles = buttonsTitles
  }
  
  func didTapPrimaryButton() {
    delegate?.exchangeReturnButtonsViewModelDidTapPrimaryButton(self)
  }
  
  func didTapCancelContractButton() {
    delegate?.exchangeReturnButtonsViewModelDidTapCancelContractButton(self)
  }
}

// MARK: - CommonTableCellViewModel

extension ExchangeReturnButtonsViewModel: CommonTableCellViewModel {
  var tableCellIdentifier: String {
    return ExchangeReturnInfoButtonsCell.reuseIdentifier
  }
}
