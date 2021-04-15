//
//  ExchangeReturnSelectStoreViewModel.swift
//  ForwardLeasing
//

import Foundation

protocol ExchangeReturnSelectStoreViewModelDelegate: class {
  func selectExchangeStoreViewModelDidRequestToSelectStore(_ viewModel: ExchangeReturnSelectStoreViewModel)
}

class ExchangeReturnSelectStoreViewModel {
  let title: String
  weak var delegate: ExchangeReturnSelectStoreViewModelDelegate?

  init(title: String) {
    self.title = title
  }

  func didTapSelectStoreButton() {
    delegate?.selectExchangeStoreViewModelDidRequestToSelectStore(self)
  }
}

// MARK: - CommonTableCellViewModel

extension ExchangeReturnSelectStoreViewModel: CommonTableCellViewModel {
  var tableCellIdentifier: String {
    return ExchangeReturnSelectStoreCell.reuseIdentifier
  }
}
