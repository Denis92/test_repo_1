//
//  ContractReturnApplicationViewModel.swift
//  ForwardLeasing
//

import Foundation

protocol ContractReturnApplicationViewModelDelegate: class {
  func contractReturnApplicationViewModelDidRequestToLayoutSuperview(_ viewModel: ContractReturnApplicationViewModel)
  func contractReturnApplicationViewModel(_ viewModel: ContractReturnApplicationViewModel,
                                          didRequestToCancelApplication application: LeasingEntity)
  func contractReturnApplicationViewModel(_ viewModel: ContractReturnApplicationViewModel,
                                          didRequestToContinueWithApplication application: LeasingEntity,
                                          state: ContractAdditionalApplicationState)
}

class ContractReturnApplicationViewModel {
  weak var delegate: ContractReturnApplicationViewModelDelegate?

  var contractReturnDescriptionViewModel: ProductStatusDescriptionViewModelProtocol? {
    guard let title = applicationTitles.statusTitle(with: state) else {
      return nil
    }
    let configuration = ProductDescriptionConfiguration(title: title, color: .access)
    return ContractReturnDescriptionViewModel(productDescriptionConfiguration: configuration)
  }

  var primaryButtonTitle: String? {
    return applicationTitles.primaryButtonTitle(with: state)
  }

  private(set) var state: ContractAdditionalApplicationState = .onDiagnostics
  private let contract: LeasingEntity
  private let applicationTitles: ContractAdditionalApplicationTitles

  init(contract: LeasingEntity) {
    self.contract = contract
    self.applicationTitles = ContractReturnApplicationTitles(contract: contract)
    updateState()
  }
  
  func didTapPrimaryButton() {
    delegate?.contractReturnApplicationViewModel(self,
                                                 didRequestToContinueWithApplication: contract,
                                                 state: state)
  }
  
  func didTapCancelApplicationButton() {
    delegate?.contractReturnApplicationViewModel(self, didRequestToCancelApplication: contract)
  }

  private func updateState() {
    switch contract.status {
    case .returnCreated
          where contract.contractActionInfo?.upgradeReturnSumPaid == false
          && contract.contractActionInfo?.upgradeReturnPaymentSum?.isZero == false :
      state = .comission
    case .returnCreated
          where contract.contractActionInfo?.upgradeReturnPaymentSum?.isZero == true :
      state = .freeExchange
    case .returnCreated
          where contract.contractActionInfo?.diagnosticType == .forward
          && contract.contractActionInfo?.checkSessionID != nil :
      state = .awaitingDiagnostics
    case .returnCreated
          where contract.contractActionInfo?.upgradeReturnSumPaid == true :
      state = .paid
    case .returnCreated:
      state = .new
    default:
      state = .onDiagnostics
    }
  }
}

// MARK: - CommonTableCellViewModel

extension ContractReturnApplicationViewModel: CommonTableCellViewModel {
  var tableCellIdentifier: String {
    return ContractReturnApplicationCell.reuseIdentifier
  }
}
