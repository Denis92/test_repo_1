//
//  ContractDetailsMakePaymentButtonViewModel.swift
//  ForwardLeasing
//

import Foundation

protocol ContractMakePaymentButtonViewModelDelegate: class {
  func contractMakePaymentButtonViewModelDidTapButton(_ viewModel: ContractMakePaymentButtonViewModel,
                                                      contract: LeasingEntity)
}

class ContractMakePaymentButtonViewModel {
  weak var delegate: ContractMakePaymentButtonViewModelDelegate?
  
  var title: String? {
    guard let priceString = contract.contractInfo?.nextPaymentSum.priceString() else { return nil }
    return R.string.contractDetails.payButtonTitle(priceString)
  }
  
  private let contract: LeasingEntity
  
  init(contract: LeasingEntity) {
    self.contract = contract
  }
  
  func didTapButton() {
    delegate?.contractMakePaymentButtonViewModelDidTapButton(self, contract: contract)
  }
}

// MARK: - CommonTableCellViewModel

extension ContractMakePaymentButtonViewModel: CommonTableCellViewModel {
  var tableCellIdentifier: String {
    return ContractMakePaymentButtonCell.reuseIdentifier
  }
}
