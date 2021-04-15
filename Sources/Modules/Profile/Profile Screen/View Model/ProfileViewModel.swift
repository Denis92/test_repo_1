//
//  ProfileViewModel.swift
//  ForwardLeasing
//

import Foundation
import PromiseKit

enum ProfileSegment: Int, CaseIterable {
  case devices
  case services

  var description: String {
    switch self {
    case .devices:
      return R.string.profile.segmentDevicesTitle()
    case .services:
      return R.string.profile.segmentServicesTitle()
    }
  }
}

protocol ProfileViewModelDelegate: class {
  func profileViewModelDidRequestShowSettings(_ viewModel: ProfileViewModel)
  func profileViewModel(_ viewModel: ProfileViewModel,
                        didRequestToShowDetailsFor leasingEntity: LeasingEntity)
  func profileViewModel(_ viewModel: ProfileViewModel,
                        didRequestShowDetailsFor subscription: BoughtSubscription)
  func profileViewModel(_ viewModel: ProfileViewModel,
                        didRequestContinueCreate leasingEntity: LeasingEntity)
  func profileViewModel(_ viewModel: ProfileViewModel, didRequestPayWithContract contract: LeasingEntity)
  func profileViewModel(_ viewModel: ProfileViewModel, didRequestBuyAgainWithSubscription subscription: BoughtSubscription)
}

class ProfileViewModel: CommonTableViewModel, BindableViewModel {
  typealias Dependencies = HasProfileService & HasSubscriptionsService
    & HasContractService & HasApplicationService & HasDeliveryService

  // MARK: - Properties
  var onDidStartRequest: (() -> Void)?
  var onDidFinishRequest: (() -> Void)?
  var onDidRequestToShowErrorBanner: ((Error) -> Void)?
  var onDidRequestToShowEmptyErrorView: ((Error) -> Void)?
  var onDidLoadData: (() -> Void)?
  var onNeedsToPerformBatchUpdates: (() -> Void)?
  var onDidRequestToCancelLeasingEntity: ((_ callback: @escaping () -> Void) -> Void)?
  var onDidRequestToShowHardcheckerError: ((_ message: String?) -> Void)?

  var sectionViewModels: [TableSectionViewModel] = []

  weak var delegate: ProfileViewModelDelegate?

  private let dependencies: Dependencies
  private let segmentedControlSection = TableSectionViewModel()
  private let productsSection = TableSectionViewModel()
  private let closedContractsViewModel = ClosedContractsViewModel()
  private var devicesCellViewModels: [CommonTableCellViewModel] = []
  private var servicesCellViewModels: [CommonTableCellViewModel] = []
  private var currentSegment: ProfileSegment = .devices
  private var leasingEntities: [LeasingEntity] = []
  
  // MARK: - Init
  init(dependencies: Dependencies) {
    self.dependencies = dependencies
    let profileSegmentedViewModel = ProfileSegmentedControlCellModel()
    profileSegmentedViewModel.delegate = self
    segmentedControlSection.append(profileSegmentedViewModel)
    closedContractsViewModel.delegate = self
    sectionViewModels.append(segmentedControlSection)
    sectionViewModels.append(productsSection)
  }

  // MARK: - Methods
  func loadData(isRefreshing: Bool = false) {
    onDidStartRequest?()
    
    if isRefreshing {
      try? dependencies.profileService.invalidateCaches(for: [ProfileCacheInfo.contracts], groups: [ContractCacheInfo.group])
    }
    
    firstly {
      when(fulfilled: dependencies.profileService.leasingContracts(), dependencies.subscriptionsService.subscriptionList())
    }.ensure {
      self.onDidFinishRequest?()
    }.done { leasingEntities, subscriptions in
      self.handle(leasingEntities)
      self.handle(subscriptions)
      self.updateEmptyStateIfNeeded(for: self.currentSegment)
      self.onDidLoadData?()
    }.catch { error in
      self.onDidRequestToShowEmptyErrorView?(error)
    }
  }
  
  func updateContractIfNeeded(_ contract: LeasingEntity) {
    if let contractIndex = leasingEntities.firstIndex(of: contract) {
      leasingEntities.remove(at: contractIndex)
      leasingEntities.insert(contract, at: contractIndex)
    }
    onDidLoadData?()
  }

  func showSettings() {
    delegate?.profileViewModelDidRequestShowSettings(self)
  }

  // MARK: - Private methods
  private func handle(_ leasingEntities: [LeasingEntity]) {
    self.leasingEntities = leasingEntities
    var activeLeasingEntities: [LeasingEntity] = []
    var closedLeasingEntities: [LeasingEntity] = []
    leasingEntities.forEach {
      if $0.status == .closed {
        closedLeasingEntities.append($0)
      } else {
        activeLeasingEntities.append($0)
      }
    }

    let upgradeApplicationIDs = activeLeasingEntities.compactMap { $0.upgradeApplicationId }

    let filtredActiveLeasingEntities = activeLeasingEntities.filter { !upgradeApplicationIDs.contains($0.applicationID) }
    
    let configurations = filtredActiveLeasingEntities.map { entity -> ProfileDeviveCellConfiguration in
      let additionalEntity = activeLeasingEntities.first { $0.applicationID == entity.upgradeApplicationId }
      return ProfileDeviveCellConfiguration(leasingEntity: entity, additionalLeasingEntity: additionalEntity)
    }

    let factory = ProfileDevicesCellViewModelsFactory(configurations: configurations,
                                                      cellDelegate: self)
    devicesCellViewModels = factory.makeCellViewModels()

    if currentSegment == .devices {
      productsSection.replace(contentsOf: devicesCellViewModels)
      closedContractsViewModel.setLeasingEntities(closedLeasingEntities)

      if !closedLeasingEntities.isEmpty {
        productsSection.append(closedContractsViewModel)
      }
    }
  }

  private func handle(_ subscriptions: [BoughtSubscription]) {
    let factory = ProfileSubscriptionsCellViewModelsFactory(subscriptions: subscriptions,
                                                            cellDelegate: self)
    servicesCellViewModels = factory.makeCellViewModels()
    if currentSegment == .services {
      productsSection.replace(contentsOf: servicesCellViewModels)
    }
  }

  private func handle(action: ProductButtonAction, with leasingEntity: LeasingEntity) {
    switch action {
    case .cancelApplication, .cancelContract:
      onDidRequestToCancelLeasingEntity? { [weak self] in
        self?.cancel(leasingEntity)
      }
    case .cancelUpgradeApplication:
      guard let application = leasingEntities.first(where: { $0.applicationID == leasingEntity.upgradeApplicationId }) else {
        return
      }
      onDidRequestToCancelLeasingEntity? { [weak self] in
        self?.cancel(application)
      }
    case .cancelReturnApplication:
      onDidRequestToCancelLeasingEntity? { [weak self] in
        self?.cancelReturn(leasingEntity)
      }
    case .cancelDelivery:
      cancelDelivery(with: leasingEntity.applicationID)
    case .pay:
      delegate?.profileViewModel(self, didRequestPayWithContract: leasingEntity)
    case .signСontract where leasingEntity.status == .approved:
      createContract(for: leasingEntity) { [weak self] in
        guard let self = self else { return }
        self.delegate?.profileViewModel(self, didRequestContinueCreate: leasingEntity)
      }
    case .upgrade, .return:
      self.delegate?.profileViewModel(self, didRequestToShowDetailsFor: leasingEntity)
    default:
      // TODO - make another handle statuses select
      // TODO: - add hardchecker to other continue flow variants in future if needed 
      checkApplicationHardcheckerStatus(leasingEntity: leasingEntity) { [weak self] in
        guard let self = self else { return }
        self.delegate?.profileViewModel(self, didRequestContinueCreate: leasingEntity)
      }
    }
  }
  private func handle(action: ProductButtonAction, with subscription: BoughtSubscription) {
    switch action {
    case .buyAgain:
      delegate?.profileViewModel(self, didRequestBuyAgainWithSubscription: subscription)
    default:
      // do nothing
      break
    }
  }
  
  private func createContract(for leasingEntity: LeasingEntity, completion: @escaping () -> Void) {
    onDidStartRequest?()
    dependencies.contractService.createContract(applicationID: leasingEntity.applicationID).ensure {
      self.onDidFinishRequest?()
    }.done { _ in
      completion()
    }.catch { error in
      self.onDidRequestToShowErrorBanner?(error)
    }
  }

  private func cancel(_ leasingEntity: LeasingEntity) {
    onDidStartRequest?()
    firstly {
      getCancelPromise(with: leasingEntity)
    }.ensure {
      self.onDidFinishRequest?()
    }.done { _ in
      self.loadData()
    }.catch { error in
      self.onDidRequestToShowErrorBanner?(error)
    }
  }
  
  private func cancelReturn(_ leasingEntity: LeasingEntity) {
    onDidStartRequest?()
    dependencies.contractService.cancelReturn(applicationID: leasingEntity.applicationID).ensure {
      self.onDidFinishRequest?()
    }.done { _ in
      self.loadData()
    }.catch { error in
      self.onDidRequestToShowErrorBanner?(error)
    }
  }

  private func cancelDelivery(with applicationID: String) {
    onDidStartRequest?()
    firstly {
      dependencies.deliveryService.cancelDelivery(applicationID: applicationID)
    }.ensure {
      self.onDidFinishRequest?()
    }.done { _ in
      self.loadData()
    }.catch { error in
      self.onDidRequestToShowErrorBanner?(error)
    }
  }

  private func getCancelPromise(with leasingEntity: LeasingEntity) -> Promise<EmptyResponse> {
    if leasingEntity.entityType == .application {
      return dependencies.applicationService.cancelApplication(applicationID: leasingEntity.applicationID)
    } else {
      return dependencies.contractService.cancelContract(applicationID: leasingEntity.applicationID)
    }
  }
  
  private func updateEmptyStateIfNeeded(for segment: ProfileSegment) {
    switch segment {
    case .devices:
      if devicesCellViewModels.isEmpty {
        productsSection.append(ProfileEmptyStateViewModel(title: R.string.profile.emptyDevicesTitle()))
      }
    case .services:
      if servicesCellViewModels.isEmpty {
        productsSection.append(ProfileEmptyStateViewModel(title: R.string.profile.emptyServicesTitle()))
      }
    }
  }
  
  private func checkApplicationHardcheckerStatus(leasingEntity: LeasingEntity, onSuccess: @escaping () -> Void) {
    guard leasingEntity.entityType == .application else {
      onSuccess()
      return
    }
    
    onDidStartRequest?()
    dependencies.applicationService.getApplicationData(applicationID: leasingEntity.applicationID).ensure {
      self.onDidFinishRequest?()
    }.done { application in
      if application.hasHardcheckerError {
        self.onDidRequestToShowHardcheckerError?(application.hardCheckText)
      } else {
        onSuccess()
      }
    }.catch { error in
      self.onDidRequestToShowErrorBanner?(error)
    }
  }
}

// MARK: - ProfileCellViewModelsDelegate
extension ProfileViewModel: ProfileCellViewModelsDelegate {
  func cellViewModel(_ cellViewModel: CommonTableCellViewModel, didSelect action: ProfileCellAction) {
    switch action {
    case .selectSegment(let segment):
      currentSegment = segment
      let viewModels = segment == .devices
        ? devicesCellViewModels
        : servicesCellViewModels
      productsSection.replace(contentsOf: viewModels)
      updateEmptyStateIfNeeded(for: segment)
      onDidLoadData?()
    case .leasingEntityAction(let action, let leasingEntity):
      handle(action: action,
             with: leasingEntity)
    case .subscriptionAction(let action, let subscription):
      handle(action: action,
             with: subscription)
    case .selectSubscription(let subscription):
      delegate?.profileViewModel(self,
                                 didRequestShowDetailsFor: subscription)
    case .selectLeasingEntity(let leasingEntity):
      guard shouldShowDetails(for: leasingEntity) else { return }
      delegate?.profileViewModel(self,
                                 didRequestToShowDetailsFor: leasingEntity)
    case .hideSubscription(let subscription):
      // TODO: Handle hide subscription
      break
    }
  }
  
  func shouldShowDetails(for leasingEntity: LeasingEntity) -> Bool {
    let contractAtDeliveryStatuses: [LeasingEntityStatus] = [.contractCreated, .deliveryCreated, .deliveryStarted]
    if contractAtDeliveryStatuses.contains(leasingEntity.status),
       leasingEntity.contractActionInfo?.deliveryInfo?.status == .cancelPayment { return false }
    return true
  }
}

// MARK: - ClosedContractsViewModelDelegate

extension ProfileViewModel: ClosedContractsViewModelDelegate {
  func closedContractsViewModelNeedsToLayoutSuperview(_ viewModel: ClosedContractsViewModel) {
    onNeedsToPerformBatchUpdates?()
  }
  
  func closedContractsViewModel(_ viewModel: ClosedContractsViewModel, didSelect leasingEntity: LeasingEntity) {
    guard leasingEntity.status != .closed else {
      return
    }
    delegate?.profileViewModel(self, didRequestToShowDetailsFor: leasingEntity)
  }
}
