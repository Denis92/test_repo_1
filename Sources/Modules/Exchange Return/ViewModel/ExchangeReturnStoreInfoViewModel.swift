//
//  ExchangeReturnStoreInfoViewModel.swift
//  ForwardLeasing
//

import UIKit

protocol ExchangeReturnStoreInfoViewModelDelegate: class {
  func exchangeReturnStoreInfoViewModelDidRequestToSelectOtherStore(_ viewModel: ExchangeReturnStoreInfoViewModel)
}

class ExchangeReturnStoreInfoViewModel: StoreInfoViewModelProtocol {
  weak var delegate: ExchangeReturnStoreInfoViewModelDelegate?
  
  let storePointInfo: StorePointInfo?
  
  init(storePointInfo: StorePointInfo?) {
    self.storePointInfo = storePointInfo
  }
  
  func didTapSelectOtherStore() {
    delegate?.exchangeReturnStoreInfoViewModelDidRequestToSelectOtherStore(self)
  }
}

// MARK: - CommonTableCellViewModel

extension ExchangeReturnStoreInfoViewModel: CommonTableCellViewModel {
  var tableCellIdentifier: String {
    return ExchangeReturnStoreInfoCell.reuseIdentifier
  }
}

// MARK: - PaddingAddingContainerViewModel

extension ExchangeReturnStoreInfoViewModel: PaddingAddingContainerViewModel {
  var padding: UIEdgeInsets {
    return UIEdgeInsets(top: 0, left: 20, bottom: 32, right: 20)
  }
}
