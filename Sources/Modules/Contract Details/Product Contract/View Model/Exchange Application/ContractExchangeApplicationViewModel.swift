//
//  ContractExchangeApplicationViewModel.swift
//  ForwardLeasing
//

import Foundation

private extension Constants {
  static let newApplicationStatuses: [LeasingEntityStatus] = [.confirmed, .dataSaved, .pending, .inReview,
                                                              .contractInit, .contractCreated, .signed, .approved]
}

enum ContractAdditionalApplicationState {
  case new, awaitingDiagnostics, comission, freeExchange, awaitingExchange,
       paid, onDiagnostics
}

protocol ContractExchangeApplicationViewModelDelegate: class {
  func contractExchangeApplicationViewModelDidRequestToLayoutSuperview(_ viewModel: ContractExchangeApplicationViewModel)
  func contractExchangeApplicationViewModel(_ viewModel: ContractExchangeApplicationViewModel,
                                            didRequestToCancelApplication application: LeasingEntity)
  func contractExchangeApplicationViewModel(_ viewModel: ContractExchangeApplicationViewModel,
                                            didRequestToContinueWithApplication application: LeasingEntity,
                                            state: ContractAdditionalApplicationState)
}

class ContractExchangeApplicationViewModel {
  typealias Dependencies = HasContractService
  
  weak var delegate: ContractExchangeApplicationViewModelDelegate?
  
  var onDidStartRequest: (() -> Void)?
  var onDidFinishRequest: (() -> Void)?
  var onDidUpdate: (() -> Void)?
  var onDidReceiveError: ((Error) -> Void)?
  
  var imageURL: URL? {
    guard let imageLink = upgradeLeasingEntity.productImage else { return nil }
    return URL(string: imageLink)
  }
  
  var productName: String {
    return upgradeLeasingEntity.productInfo.goodName ?? ""
  }
  
  var monthPayment: String {
    guard let price = upgradeLeasingEntity.productInfo.monthPay?.priceString() else { return "" }
    return R.string.contractDetails.exchangeMonthPrice(price)
  }

  var primaryButtonTitle: String? {
    return applicationTitles.primaryButtonTitle(with: state)
  }

  var statusTitle: String? {
    return applicationTitles.statusTitle(with: state)
  }

  var hintTitle: String? {
    return R.string.contractDetails.exchangeApplicationHintText()
  }

  private(set) var state: ContractAdditionalApplicationState = .onDiagnostics
  
  private let contract: LeasingEntity
  private let dependencies: Dependencies
  private let applicationTitles: ContractAdditionalApplicationTitles
  
  private var hasAttemptToLoadData = false
  private var upgradeLeasingEntity: LeasingEntity
  
  init(contract: LeasingEntity, upgradeLeasingEntity: LeasingEntity, dependencies: Dependencies) {
    self.contract = contract
    self.upgradeLeasingEntity = upgradeLeasingEntity
    self.dependencies = dependencies
    self.applicationTitles = ContractExchangeApplicationTitles()
    updateState()
  }
  
  func didTapPrimaryButton() {
    if state == .new && upgradeLeasingEntity.status == .approved {
      createContract(for: upgradeLeasingEntity) { [weak self] in
        guard let self = self else {
          return
        }
        self.delegate?.contractExchangeApplicationViewModel(self,
                                                            didRequestToContinueWithApplication: self.upgradeLeasingEntity,
                                                            state: self.state)
      }
    } else {
      delegate?.contractExchangeApplicationViewModel(self,
                                                     didRequestToContinueWithApplication: upgradeLeasingEntity,
                                                     state: state)
    }
  }
  
  func didTapCancelApplicationButton() {
    delegate?.contractExchangeApplicationViewModel(self, didRequestToCancelApplication: upgradeLeasingEntity)
  }

  private func createContract(for leasingEntity: LeasingEntity, completion: @escaping () -> Void) {
    onDidStartRequest?()
    dependencies.contractService.createContract(applicationID: leasingEntity.applicationID).ensure {
      self.onDidFinishRequest?()
    }.done { _ in
      completion()
    }.catch { error in
      self.onDidReceiveError?(error)
    }
  }

  private func updateState() {
    // TODO: - Handle diagnotic state and awainting exhcange state (when user closed app on final screen)
    
    if upgradeLeasingEntity.contractActionInfo?.upgradeReturnSumPaid == true {
      state = .paid
      return
    }
    
    if upgradeLeasingEntity.status == .signed, upgradeLeasingEntity.contractActionInfo?.upgradeReturnPaymentSum?.isZero == true {
      state = .freeExchange
      return
    }
    
    if upgradeLeasingEntity.status == .signed,
       let sum = upgradeLeasingEntity.contractActionInfo?.upgradeReturnPaymentSum, sum > 0 {
      state = .comission
      return
    }
    
    if upgradeLeasingEntity.status == .signed, upgradeLeasingEntity.contractActionInfo?.diagnosticType == .forward,
       !(upgradeLeasingEntity.contractActionInfo?.checkSessionID.isEmptyOrNil ?? true) {
      state = .awaitingDiagnostics
      return
    }
    
    if contract.status == .upgradeCreated, Constants.newApplicationStatuses.contains(upgradeLeasingEntity.status) {
      state = .new
      return
    }
    onDidUpdate?()
  }
}

// MARK: - CommonTableCellViewModel

extension ContractExchangeApplicationViewModel: CommonTableCellViewModel {
  var tableCellIdentifier: String {
    return ContractExchangeApplicationCell.reuseIdentifier
  }
}
