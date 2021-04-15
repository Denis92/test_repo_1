//
//  ContractDetailsViewModel.swift
//  ForwardLeasing
//

import Foundation
import PromiseKit

protocol ContractDetailsViewModelDelegate: class {
  func contractDetailsViewModel(_ viewModel: ContractDetailsViewModel,
                                didRequestToMakePaymentWith contract: LeasingEntity)
  func contractDetailsViewModel(_ viewModel: ContractDetailsViewModel,
                                didRequestToExchangeProductToModel model: ModelInfo,
                                contract: LeasingEntity)
  func contractDetailsViewModel(_ viewModel: ContractDetailsViewModel,
                                didRequestToContinueExchangeWith contract: LeasingEntity)
  func contractDetailsViewModel(_ viewModel: ContractDetailsViewModel,
                                didRequestOpenURL url: URL)
  func contractDetailsViewModel(_ viewModel: ContractDetailsViewModel,
                                didRequestShowPDFDocuments pdfDocuments: [ContractDocument])
  func contractDetailsViewModel(_ viewModel: ContractDetailsViewModel, didUpdateContract contract: LeasingEntity)
  func contractDetailsViewModel(_ viewModel: ContractDetailsViewModel,
                                didRequestToReturnProductWith contract: LeasingEntity)
}

// TODO: - Remove later if no needed
enum ContractDetailsError: Error {
  case notInBackoffice
}

class ContractDetailsViewModel: CommonTableViewModel, BindableViewModel {
  typealias Dependencies = HasContractService & HasDeliveryService & HasCatalogueService & HasApplicationService
  
  // MARK: - Properties
  weak var delegate: ContractDetailsViewModelDelegate?
  
  var onDidStartRequest: (() -> Void)?
  var onDidFinishRequest: (() -> Void)?
  var onDidRequestToShowErrorBanner: ((Error) -> Void)?
  var onDidRequestToShowEmptyErrorView: ((Error) -> Void)?
  var onDidLoadData: (() -> Void)?
  var onNeedsToPerformBatchUpdates: (() -> Void)?
  var onDidRequestShowAlertWithMessage: ((String) -> Void)?
  var onDidRequestToDeleteSection: ((_ index: Int) -> Void)?
  var onDidUpdateDetailsInfoViewModel: ((ContractDetailsInfoViewModel) -> Void)?
  var onDidRequestToCancelLeasingEntity: ((_ callback: @escaping () -> Void) -> Void)?
  var onDidRequestToPresentActivityIndicator: (() -> Void)?
  var onDidRequestToHideActivityIndicator: (() -> Void)?
  
  var title: String? {
    return contract?.productInfo.goodName
  }
  
  private let dependencies: Dependencies
  private var contract: LeasingEntity? {
    didSet {
      guard let contract = contract else { return }
      delegate?.contractDetailsViewModel(self, didUpdateContract: contract)
    }
  }
  
  private let applicationID: String
  private(set) var exchangeOptionsViewModel: ExchangeOptionsViewModel?
  private var exchangeOfferModels: [ModelInfo] = []
  private(set) var sectionViewModels: [TableSectionViewModel] = []
  private(set) var deliveryViewModel: TableSectionViewModel?
  private(set) var infoViewModel: ContractDetailsInfoViewModel? {
    didSet {
      guard let infoViewModel = infoViewModel else { return }
      onDidUpdateDetailsInfoViewModel?(infoViewModel)
    }
  }
  
  // MARK: - Init
  
  init(dependencies: Dependencies, applicationID: String) {
    self.applicationID = applicationID
    self.dependencies = dependencies
  }
  
  // MARK: - Public methods
  func showPDFDocuments() {
    guard let contract = contract else { return }
    let documents = contract.printDocuments.map { document in
      return ContractDocument(title: document.name.isEmptyOrNil ? R.string.contractDetails.documentDefaultTitle() : document.name,
                              url: document.documentURL)
    }
    delegate?.contractDetailsViewModel(self, didRequestShowPDFDocuments: documents)
  }
  
  func loadData(isRefreshing: Bool = false) {
    onDidStartRequest?()

    if isRefreshing {
      try? dependencies.contractService.invalidateCaches(for: [ContractCacheInfo.contract(applicationID: applicationID)],
                                                         groups: [])
    }

    firstly {
      dependencies.contractService.getContract(applicationID: applicationID, useCache: true).map(\.clientLeasingEntity)
    }.then { contract -> Promise<(LeasingEntity, ProductDetails)> in
      self.contract = contract
      self.infoViewModel = ContractDetailsViewModelsFactory.makeInfoViewModel(contract: contract)
      return when(fulfilled: Promise.value(contract),
                  self.dependencies.catalogueService.getProductInfo(productCode: contract.productInfo.goodCode ?? "").map(\.product))
    }.then { contract, productDetails -> Promise<(LeasingEntity, ProductDetails, [ModelInfo], LeasingEntity?)> in
      return when(fulfilled: Promise.value(contract),
                  Promise.value(productDetails),
                  self.getExchangeModels(with: contract),
                  self.getUpgradeApplication(with: contract))
    }.done { contract, productDetails, excahngeModels, upgradeLeasingEntity in
      self.handle(contract: contract,
                  product: productDetails,
                  exchangeModels: excahngeModels,
                  upgradeLeasingEntity: upgradeLeasingEntity)
    }.ensure {
      self.onDidFinishRequest?()
    }.catch { error in
      self.onDidRequestToShowEmptyErrorView?(error)
    }
  }

  // MARK: - Private methods
  private func getExchangeModels(with contract: LeasingEntity) -> Promise<[ModelInfo]> {
    guard contract.contractInfo?.upgradeReturnEnabled == true else {
      return Promise.value([])
    }
    if contract.status == .inBackoffice {
      return dependencies.contractService.getExchangeOffers(applicationID: contract.applicationID).map(\.models)
    } else {
      return Promise.value([])
    }
  }

  private func getUpgradeApplication(with contract: LeasingEntity) -> Promise<LeasingEntity?> {
    guard let upgradeApplicationId = contract.upgradeApplicationId else {
      return Promise.value(nil)
    }
    return Promise { seal in
      firstly {
        dependencies.contractService.getContract(applicationID: upgradeApplicationId, useCache: true).map(\.clientLeasingEntity)
      }.done { upgradeApplication in
        return seal.fulfill(upgradeApplication)
      }.catch { error in
        if case NetworkRequestError.emptyResultData = error {
          return seal.fulfill(nil)
        } else {
          seal.reject(error)
        }
      }
    }
  }

  private func handle(contract: LeasingEntity,
                      product: ProductDetails,
                      exchangeModels: [ModelInfo],
                      upgradeLeasingEntity: LeasingEntity?) {
    sectionViewModels.removeAll()
    switch contract.status {
    case .inBackoffice, .upgradeCreated, .returnCreated, .signed:
      if contract.contractInfo?.nextPaymentSum.isZero != true {
        sectionViewModels.append(ContractDetailsViewModelsFactory.makePaymentButtonSectionViewModel(contract: contract,
                                                                                                    delegate: self))
      }
      if contract.status == .upgradeCreated, let upgradeLeasingEntity = upgradeLeasingEntity {
        sectionViewModels.append(ContractDetailsViewModelsFactory
                                  .makeExchangeApplicationSectionViewModel(contract: contract,
                                                                           upgradeLeasingEntity: upgradeLeasingEntity,
                                                                           delegate: self,
                                                                           dependencies: dependencies))
      }
      if contract.status == .returnCreated {
        sectionViewModels.append(ContractDetailsViewModelsFactory
                                  .makeReturnApplicationSectionViewModel(contract: contract,
                                                                         delegate: self))
      }
      appendAboutProductIfNeeded(with: product)
      if !exchangeModels.isEmpty {
        sectionViewModels.append(ContractDetailsViewModelsFactory.makeExchangeSectionViewModel(contract: contract,
                                                                                               models: exchangeModels,
                                                                                               delegate: self))
      }

      sectionViewModels.append(ContractDetailsViewModelsFactory.makePaymentScheduleSectionViewModel(contract: contract,
                                                                                                    delegate: self))
      sectionViewModels.append(ContractDetailsViewModelsFactory.makeAdditionalInfoViewModel(contract: contract,
                                                                                            upgradeLeasingEntity: upgradeLeasingEntity,
                                                                                            delegate: self))

    case .deliveryStarted, .deliveryCreated, .deliveryShipped, .deliveryCompleted:
      appendAboutProductIfNeeded(with: product)

      let deliveryViewModel = ContractDetailsViewModelsFactory.makeDeliveryViewModel(dependencies: dependencies,
                                                                                     contract: contract)
      sectionViewModels.append(deliveryViewModel)

    default:
      break
    }
    onDidLoadData?()
  }

  private func appendAboutProductIfNeeded(with productDetails: ProductDetails) {
    if let description = productDetails.description {
      sectionViewModels.append(ContractDetailsViewModelsFactory.makeAboutProductSectionViewModel(description: description))
    }
  }

  private func buyout() {
    // TODO - buyout request
  }
  
  private func returnProduct() {
    guard let contract = contract else { return }
    delegate?.contractDetailsViewModel(self, didRequestToReturnProductWith: contract)
  }
  
  private func cancelExchangeApplication(application: LeasingEntity, completion: (() -> Void)?) {

    getCancelExchangePromise(for: application).done { _ in
      completion?()
      if let index = self.sectionViewModels.firstIndex(where: { $0.cellViewModels.first
                                                        is ContractAdditionalViewModel<ContractExchangeApplicationViewModel> }) {
        self.sectionViewModels.remove(at: index)
        self.onDidRequestToDeleteSection?(index)
      }
    }.catch { error in
      completion?()
      self.onDidRequestToShowErrorBanner?(error)
    }
  }

  private func cancelReturnApplication(application: LeasingEntity, completion: (() -> Void)?) {

    getCancelReturnPromise(for: application).done { _ in
      completion?()
      if let index = self.sectionViewModels.firstIndex(where: { $0.cellViewModels.first
                                                        is ContractAdditionalViewModel<ContractReturnApplicationViewModel> }) {
        self.sectionViewModels.remove(at: index)
        self.onDidRequestToDeleteSection?(index)
      }
    }.catch { error in
      completion?()
      self.onDidRequestToShowErrorBanner?(error)
    }
  }

  private func getCancelExchangePromise(for leasingEntity: LeasingEntity) -> Promise<EmptyResponse> {
    return leasingEntity.entityType == .application
      ? dependencies.applicationService.cancelApplication(applicationID: leasingEntity.applicationID)
      : dependencies.contractService.cancelContract(applicationID: leasingEntity.applicationID)
  }

  private func getCancelReturnPromise(for leasingEntity: LeasingEntity) -> Promise<EmptyResponse> {
    return leasingEntity.entityType == .application
      ? dependencies.applicationService.cancelReturnApplication(applicationID: leasingEntity.applicationID)
      : dependencies.contractService.cancelReturn(applicationID: leasingEntity.applicationID)
  }

}

// MARK: - ContractMakePaymentButtonViewModelDelegate

extension ContractDetailsViewModel: ContractMakePaymentButtonViewModelDelegate {
  func contractMakePaymentButtonViewModelDidTapButton(_ viewModel: ContractMakePaymentButtonViewModel,
                                                      contract: LeasingEntity) {
    delegate?.contractDetailsViewModel(self, didRequestToMakePaymentWith: contract)
  }
}

// MARK: - ExchangeOptionsViewModelDelegate

extension ContractDetailsViewModel: ExchangeOptionsViewModelDelegate {
  func exchangeOptionsViewModel(_ viewModel: ExchangeOptionsViewModel, didSelectModel model: ModelInfo) {
    guard let contract = contract else { return }
    delegate?.contractDetailsViewModel(self, didRequestToExchangeProductToModel: model, contract: contract)
  }
}

// MARK: - ContractDetailsAdditionalInfoViewModelDelegate

extension ContractDetailsViewModel: ContractDetailsAdditionalInfoViewModelDelegate {
  func contractDetailsAdditionalInfoViewModel(_ viewModel: ContractDetailsAdditionalInfoViewModel,
                                              didRequestShowAlertWithMessage message: String) {
    onDidRequestShowAlertWithMessage?(message)
  }
  
  func contractDetailsAdditionInfoViewModelDidRequestLayout(_ viewModel: ContractDetailsAdditionalInfoViewModel) {
    onNeedsToPerformBatchUpdates?()
  }
  
  func contractDetailsAdditionalInfoViewModelDidRequestBuyout(_ viewModel: ContractDetailsAdditionalInfoViewModel) {
    buyout()
  }
  
  func contractDetailsAdditionalInfoViewModelDidRequestMakeReturn(_ viewModel: ContractDetailsAdditionalInfoViewModel) {
    returnProduct()
  }
  
  func contractDetailsAdditionalInfoViewModel(_ viewModel: ContractDetailsAdditionalInfoViewModel, didRequestOpenURL url: URL) {
    delegate?.contractDetailsViewModel(self, didRequestOpenURL: url)
  }
}

// MARK: - PaymentScheduleViewModelDelegate

extension ContractDetailsViewModel: PaymentScheduleViewModelDelegate {
  func paymentScheduleViewModelDidRequestToLayoutSuperview(_ viewModel: PaymentScheduleViewModel) {
    onNeedsToPerformBatchUpdates?()
  }
}

// MARK: - ContractExchangeApplicationViewModelDelegate

extension ContractDetailsViewModel: ContractExchangeApplicationViewModelDelegate {
  func contractExchangeApplicationViewModelDidRequestToLayoutSuperview(_ viewModel: ContractExchangeApplicationViewModel) {
    onNeedsToPerformBatchUpdates?()
  }
  
  func contractExchangeApplicationViewModel(_ viewModel: ContractExchangeApplicationViewModel,
                                            didRequestToCancelApplication application: LeasingEntity) {
    onDidRequestToCancelLeasingEntity? { [weak self] in
      self?.onDidRequestToPresentActivityIndicator?()
      self?.cancelExchangeApplication(application: application) { [weak self] in
        self?.onDidRequestToHideActivityIndicator?()
      }
    }
  }
  
  func contractExchangeApplicationViewModel(_ viewModel: ContractExchangeApplicationViewModel,
                                            didRequestToContinueWithApplication application: LeasingEntity,
                                            state: ContractAdditionalApplicationState) {
    delegate?.contractDetailsViewModel(self,
                                       didRequestToContinueExchangeWith: application)
  }
}

// MARK: - ContractReturnApplicationViewModelDelegate

extension ContractDetailsViewModel: ContractReturnApplicationViewModelDelegate {
  func contractReturnApplicationViewModelDidRequestToLayoutSuperview(_ viewModel: ContractReturnApplicationViewModel) {
    onNeedsToPerformBatchUpdates?()
  }

  func contractReturnApplicationViewModel(_ viewModel: ContractReturnApplicationViewModel,
                                          didRequestToCancelApplication application: LeasingEntity) {
    onDidRequestToCancelLeasingEntity? { [weak self] in
      self?.onDidRequestToPresentActivityIndicator?()
      self?.cancelReturnApplication(application: application) { [weak self] in
        self?.onDidRequestToHideActivityIndicator?()
      }
    }
  }

  func contractReturnApplicationViewModel(_ viewModel: ContractReturnApplicationViewModel,
                                          didRequestToContinueWithApplication application: LeasingEntity,
                                          state: ContractAdditionalApplicationState) {
    delegate?.contractDetailsViewModel(self, didRequestToReturnProductWith: application)
  }
}
