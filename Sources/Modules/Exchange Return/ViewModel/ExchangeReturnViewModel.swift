//
//  ExchangeReturnViewModel.swift
//  ForwardLeasing
//

import Foundation
import PromiseKit

private extension Constants {
  static let refreshInterval: TimeInterval = 60
}

protocol ExchangeReturnViewModelDelegate: class {
  func exchangeReturnViewModel(_ viewModel: ExchangeReturnViewModel, didRequestToShowWebViewWith url: URL)
  func exchangeReturnViewModel(_ viewModel: ExchangeReturnViewModel, didRequestToSelectStoreFor contract: LeasingEntity)
  func exchangeReturnViewModel(_ viewModel: ExchangeReturnViewModel, didRequestDiagnosticFor contract: LeasingEntity)
  func exchangeReturnViewModel(_ viewModel: ExchangeReturnViewModel, didRequestPaymentWith url: URL)
  func exchangeReturnViewModelDidCancelContract(_ viewModel: ExchangeReturnViewModel)
  func exchangeReturnViewModelDidFinish(_ viewModel: ExchangeReturnViewModel)
}

enum ExchangeReturnState {
  case selectStore, awatingDiagnostics, passDiagnostics, payForExhcange, freeExchange, complete
}

class ExchangeReturnViewModel: BindableViewModel, CommonTableViewModel {
  typealias Dependencies = HasContractService & HasDeliveryService & HasPaymentsService & HasUserDataStore
  
  // MARK: - Properties
  
  weak var delegate: ExchangeReturnViewModelDelegate?
  
  var onDidStartRequest: (() -> Void)?
  var onDidFinishRequest: (() -> Void)?
  var onDidRequestToShowErrorBanner: ((Error) -> Void)?
  var onDidRequestToShowEmptyErrorView: ((Error) -> Void)?
  var onDidLoadData: (() -> Void)?
  var onDidRequestToCancelContract: (() -> Void)?
  
  var screenTitle: String? {
    return input.screenTitle
  }
  
  private(set) var sectionViewModels: [TableSectionViewModel] = []
  
  private let input: ExchangeReturnViewModelInput
  private let dependencies: Dependencies
  
  private var contract: LeasingEntity?
  private var state: ExchangeReturnState
  private var refreshTimer: Timer?
  private var storePoint: StorePointInfo?

  private var applicationID: String {
    return input.applicationID
  }

  private var buttonsViewModel: ExchangeReturnButtonsViewModel? {
    let cellViewModels = sectionViewModels.flatMap { $0.cellViewModels }
    guard let index = cellViewModels.firstIndex(where: { $0 is  ExchangeReturnButtonsViewModel}) else {
      return nil
    }
    return cellViewModels[index] as? ExchangeReturnButtonsViewModel
  }
  
  // MARK: - Init
  
  init(dependencies: Dependencies, input: ExchangeReturnViewModelInput) {
    self.input = input
    self.state = .selectStore
    self.dependencies = dependencies
  }
  
  // MARK: - Public methods
  
  func loadData(isRefreshing: Bool) {
    loadData(isRefreshing: isRefreshing, inBackground: false)
  }
  
  func loadData(isRefreshing: Bool = false, inBackground: Bool = false) {
    if !inBackground {
      onDidStartRequest?()
    }
    firstly {
      saveStorePointIfNeeded()
    }.then {
      self.dependencies.contractService.getContract(applicationID: self.applicationID,
                                                    useCache: false)
    }.ensure {
      self.onDidFinishRequest?()
    }.done { response in
      self.contract = response.clientLeasingEntity
      self.state = self.getState(with: response.clientLeasingEntity)
      self.storePoint = nil
      self.updateState()
      self.onDidLoadData?()
    }.catch { error in
      guard !inBackground else { return }
      if isRefreshing {
        self.onDidRequestToShowErrorBanner?(error)
      } else {
        self.onDidRequestToShowEmptyErrorView?(error)
      }
    }
  }
  
  func cancelContract() {
    onDidStartRequest?()
    input.cancelStrategy.cancel(with: applicationID).ensure {
      self.onDidFinishRequest?()
      self.onDidLoadData?()
    }.done { _ in
      self.delegate?.exchangeReturnViewModelDidCancelContract(self)
    }.catch { error in
      self.onDidRequestToShowErrorBanner?(error)
    }
  }
  
  func invalidateRefreshTimer() {
    refreshTimer?.invalidate()
    refreshTimer = nil
  }
  
  func updateStorePoint(_ storePoint: StorePointInfo) {
    self.storePoint = storePoint
  }
  
  func startBackgroundUpdatesIfNeeded() {
    if state == .awatingDiagnostics {
      if !(contract?.contractActionInfo?.checkSessionID.isEmptyOrNil ?? true) {
        state = .passDiagnostics
        refreshTimer?.invalidate()
        refreshTimer = nil
      } else if refreshTimer == nil {
        startBackgroundRefreshing()
      }
    }
  }
  
  // MARK: - Private methods
  private func saveStorePointIfNeeded() -> Promise<Void> {
    guard let storePoint = storePoint else {
      return Promise.value(())
    }
    return dependencies.deliveryService.setStore(applicationID: applicationID, storePoint: storePoint).asVoid()
  }
  
  private func updateState() {
    startBackgroundUpdatesIfNeeded()
    makeSections()
  }
  
  private func makeSections() {
    sectionViewModels.removeAll()
    
    if state == .complete {
      sectionViewModels.append(ExchangeReturnFactory.makeCompleteTitleViewModel(title: input.completeTitle))
    }

    if input.needsContractInfo {
      sectionViewModels.append(ExchangeReturnFactory.makeNewLeasingContractSectionViewModel(delegate: self))
    }

    if let contractNumber = contract?.contractNumber, contract?.contractActionInfo?.storePoint != nil {
      sectionViewModels.append(ExchangeReturnFactory.makeBarcodeSectionViewModel(contractNumber: contractNumber,
                                                                                 exchangeInfoState: state,
                                                                                 barcodeTitles: input.barcodeTitles))
    }
    
    if state != .complete {
      let earlyExchangePayment = (contract?.contractInfo?.paymentsToFreeUpgrade == 0)
        ? nil : contract?.productInfo.upgradePayment
      let totalPayment = contract?.contractActionInfo?.upgradeReturnPaymentSum
      sectionViewModels.append(ExchangeReturnFactory.makeExchangePriceSectionViewModel(earlyExchangePayment: earlyExchangePayment,
                                                                                       totalPayment: totalPayment,
                                                                                       priceViewModelTitles: input.priceViewModelTitles))
    }
    
    if state == .selectStore || state == .awatingDiagnostics {
      if let storePointInfo = contract?.contractActionInfo?.storePoint {
        sectionViewModels.append(ExchangeReturnFactory.makeStoreInfoSectionViewModel(storePointInfo: storePointInfo,
                                                                                     delegate: self))
      } else {
        sectionViewModels.append(ExchangeReturnFactory.makeSelectExchangeStoreSectionViewModel(selectStoreTitle: input.selectStoreTitle,
                                                                                               delegate: self))
      }
    }
    
    sectionViewModels.append(ExchangeReturnFactory.makeExchangeInfoButtonsSectionViewModel(exchangeInfoState: state,
                                                                                           buttonsTitles: input.buttonsTitles,
                                                                                           delegate: self))
  }
  
  private func startBackgroundRefreshing() {
    refreshTimer = Timer.scheduledTimer(withTimeInterval: Constants.refreshInterval, repeats: true) { [weak self] _ in
      self?.loadData(inBackground: true)
    }
  }
  
  private func getState(with contract: LeasingEntity) -> ExchangeReturnState {
    return input.stateStrategy.getState(with: contract,
                                        lastDiagnosticSessionID: dependencies.userDataStore.lastDiagnosticSessionID)
  }
  
  private func pay(with leasingEntity: LeasingEntity) {
    guard let paymentInfo = input.paymentInfoStrategy.makePaymentInfo(with: leasingEntity) else {
      return
    }
    buttonsViewModel?.onDidStartRequest?()
    firstly {
      dependencies.paymentsService.pay(paymentInfo: paymentInfo)
    }.ensure {
      self.buttonsViewModel?.onDidFinishRequest?()
    }.done { response in
      self.delegate?.exchangeReturnViewModel(self, didRequestPaymentWith: response.paymentInfo.paymentURL)
    }.catch { error in
      self.onDidRequestToShowErrorBanner?(error)
    }
  }
  
}

// MARK: - NewLeasingContractPDFViewModelDelegate

extension ExchangeReturnViewModel: NewLeasingContractPDFViewModelDelegate {
  func newLeasingContractPDFViewModelDidRequestToShowPDF(_ viewModel: NewLeasingContractPDFViewModel) {
    guard let url = URL(string: URLFactory.Cabinet.signedContractPDF(applicationID: applicationID)) else { return }
    delegate?.exchangeReturnViewModel(self, didRequestToShowWebViewWith: url)
  }
}

// MARK: - ExchangeReturnSelectStoreViewModelDelegate

extension ExchangeReturnViewModel: ExchangeReturnSelectStoreViewModelDelegate {
  func selectExchangeStoreViewModelDidRequestToSelectStore(_ viewModel: ExchangeReturnSelectStoreViewModel) {
    guard let contract = contract else { return }
    delegate?.exchangeReturnViewModel(self, didRequestToSelectStoreFor: contract)
  }
}

// MARK: - ExchangeReturnStoreInfoViewModelDelegate

extension ExchangeReturnViewModel: ExchangeReturnStoreInfoViewModelDelegate {
  func exchangeReturnStoreInfoViewModelDidRequestToSelectOtherStore(_ viewModel: ExchangeReturnStoreInfoViewModel) {
    guard let contract = contract else { return }
    delegate?.exchangeReturnViewModel(self, didRequestToSelectStoreFor: contract)
  }
}

// MARK: - ExchangeReturnInfoButtonsViewModelDelegate

extension ExchangeReturnViewModel: ExchangeReturnButtonsViewModelDelegate {
  func exchangeReturnButtonsViewModelDidTapPrimaryButton(_ viewModel: ExchangeReturnButtonsViewModel) {
    guard let contract = contract else {
      return
    }
    switch state {
    case .passDiagnostics:
      delegate?.exchangeReturnViewModel(self, didRequestDiagnosticFor: contract)
    case .payForExhcange:
      pay(with: contract)
    case .complete:
      delegate?.exchangeReturnViewModelDidFinish(self)
    default:
      break
    }
  }
  
  func exchangeReturnButtonsViewModelDidTapCancelContractButton(_ viewModel: ExchangeReturnButtonsViewModel) {
    onDidRequestToCancelContract?()
  }
}
