//
//  ExchangeCoordinator.swift
//  ForwardLeasing
//

import Foundation
import FLDiagnostic

enum ExchangeCoordinatorFlow {
  case start(LeasingEntity, ModelInfo)
  case `continue`(LeasingEntity)
}

struct ExchangeCoordinatorConfiguration {
  let flow: ExchangeCoordinatorFlow
}

class ExchangeCoordinator: ConfigurableNavigationFlowCoordinator {
  typealias Configuration = ExchangeCoordinatorConfiguration
  
  // MARK: - Properties
  
  let appDependency: AppDependency
  let navigationObserver: NavigationObserver
  let navigationController: NavigationController
  var childCoordinators: [BaseCoordinator] = []
  var onDidFinish: (() -> Void)?
  
  private var onDidRequestShowQuestionnary: (() -> Void)?
  private var onDidRequestPopToStart: (() -> Void)?
  private var onDidRequestUpdateExchangeInfo: (() -> Void)?
  private var onDidRequestUpdateStorePoint: ((StorePointInfo) -> Void)?
  
  private let configuration: Configuration
  
  required init(appDependency: AppDependency,
                navigationController: NavigationController,
                navigationObserver: NavigationObserver,
                configuration: Configuration) {
    self.appDependency = appDependency
    self.navigationController = navigationController
    self.navigationObserver = navigationObserver
    self.configuration = configuration
  }
  
  func start(animated: Bool) {
    let topViewController = navigationController.topViewController
    onDidRequestPopToStart = { [weak self, weak topViewController] in
      guard let navigationController = self?.navigationController,
            let viewController = topViewController else {
        return
      }
      navigationController.presentedViewController?.dismiss(animated: false, completion: nil)
      navigationController.popToViewController(viewController, animated: true)
      self?.onDidFinish?()
    }
    switch configuration.flow {
    case .start(_, let exchangeModel):
      showProductDetails(modelInfo: exchangeModel, animated: animated)
    case .continue(let leasingEntity):
      continueExchangeFlow(with: leasingEntity)
    }
  }
  
  private func continueExchangeFlow(with leasingEntity: LeasingEntity) {
    switch leasingEntity.status {
    case .pending, .dataSaved, .confirmed, .inReview, .contractInit, .contractCreated, .approved:
      showCreateLeasingApplicationScreen(with: leasingEntity)
    case .signed:
      showExchangeInfoScreen(applicationID: leasingEntity.applicationID)
    default:
      break
    }
  }
  
  private func showProductDetails(modelInfo: ModelInfo, animated: Bool) {
    let configuration = ProductDetailsCoordinatorConfiguration(bottomButtonType: .exchange,
                                                               modelCode: modelInfo.code)
    let coordinator = show(ProductDetailsCoordinator.self, configuration: configuration, animated: animated)
    coordinator.delegate = self
  }
  
  private func showOnboardingScreen(product: ProductDetails) {
    let configuration = OnboardingCoordinatorConfiguration(type: .exchange)
    let coordinator = show(OnboardingCoordinator.self, configuration: configuration, animated: true)
    coordinator.delegate = self
  }
  
  private func showQuestionnary(product: ProductDetails) {
    guard case let .start(contract, _) = configuration.flow else {
      return
    }
    let flow = QuestionnaireFlow.exchange(productDetails: product)
    let configuration = QuestionnaireCoordinatorConfiguration(flow: flow, contract: contract)
    let coordinator = show(QuestionnaireCoordinator.self, configuration: configuration, animated: true)
    coordinator.delegate = self
  }
  
  private func showDiagnosticOrContinue(with leasingEntity: LeasingEntity) {
    guard let sessionID = leasingEntity.contractActionInfo?.checkSessionID,
          let sessionURL = leasingEntity.contractActionInfo?.checkSessionURL else {
      return
    }
    appDependency.diagnosticService.showDiagnosticOrContinue(with: sessionID, sessionURL: sessionURL).ensure {
      self.onDidRequestPopToStart?()
    }.cauterize()
  }
  
  private func showContractDetails(with leasingEntity: LeasingEntity) {
    let configuration = ContractDetailsCoordinatorConfiguration(applicationID: leasingEntity.applicationID)
    let coordinator = show(ContractDetailsCoordinator.self, configuration: configuration, animated: true)
    coordinator.delegate = self
  }
  
  private func showExchangeInfoScreen(applicationID: String) {
    let cancelStrategy = ExchangeCancelStrategy(contractService: appDependency.contractService)
    let input = ExchangeViewModelInput(cancelStrategy: cancelStrategy,
                                       applicationID: applicationID)
    let viewModel = ExchangeReturnViewModel(dependencies: appDependency,
                                          input: input)
    onDidRequestUpdateExchangeInfo = { [weak viewModel] in
      viewModel?.loadData()
    }
    onDidRequestUpdateStorePoint = { [weak viewModel] storePoint in
      viewModel?.updateStorePoint(storePoint)
    }
    viewModel.delegate = self
    let viewController = ExchangeReturnViewController(viewModel: viewModel)
    viewController.delegate = self
    navigationController.pushViewController(viewController, animated: true)
  }
  
  private func showWebView(url: URL) {
    let viewController = WebViewController(url: url, token: appDependency.tokenStorage.accessToken)
    navigationController.pushViewController(viewController, animated: true)
  }
  
  private func showCreateLeasingApplicationScreen(with basketID: String, for productDetails: ProductDetails) {
    guard case let .start(contract, _) = configuration.flow else {
      return
    }
    let configuration = CreateApplicationFlow.newUpgrade(product: productDetails.leasingInfo,
                                                         basketID: basketID,
                                                         previousApplicationID: contract.applicationID)
    let coordinator = show(CreateApplicationCoordinator.self, configuration: configuration,
                           animated: true)
    coordinator.delegate = self
  }
  
  private func showCreateLeasingApplicationScreen(with leasingEntity: LeasingEntity) {
    let configuration = CreateApplicationFlow.continueUpgrade(applictaion: leasingEntity)
    let coordinator = show(CreateApplicationCoordinator.self, configuration: configuration,
                           animated: true)
    coordinator.delegate = self
  }
  
  private func showStorePoints(with leasingEntity: LeasingEntity,
                               storePoint: StorePointInfo?) {
    let configuration = StorePointsCoordinatorConfiguration(leasingEntity: leasingEntity,
                                                            storePoint: storePoint)
    
    let coordinator = show(StorePointsCoordinator.self, configuration: configuration, animated: true)
    coordinator.delegate = self
  }
  
  private func showPayment(with url: URL) {
    let configuration = PaymentCoordinatorConfiguration(paymentURL: url)
    let coordinator = show(PaymentCoordinator.self, configuration: configuration, animated: true)
    coordinator.delegate = self
  }
}

// MARK: - ProductDetailsCoordinatorDelegate

extension ExchangeCoordinator: ProductDetailsCoordinatorDelegate {
  func productDetailsCoordinatorDidFinish(_ coordinator: ProductDetailsCoordinator) {
    navigationController.popViewController(animated: true)
    onDidFinish?()
  }
  
  func productDetailsCoordinatorDidRequestToPopToProfile(_ coordinator: ProductDetailsCoordinator) {
    navigationController.popViewController(animated: true)
  }
  
  func productDetailsCoordinator(_ coordinator: ProductDetailsCoordinator,
                                 didRequestToExchangeToProduct product: ProductDetails) {
    if appDependency.userDataStore.hasShownExchangeOnboarding {
      showQuestionnary(product: product)
    } else {
      showOnboardingScreen(product: product)
      onDidRequestShowQuestionnary = { [weak self] in
        self?.showQuestionnary(product: product)
      }
    }
  }
}

// MARK: - OnboardingCoordinatorDelegate

extension ExchangeCoordinator: OnboardingCoordinatorDelegate {
  func onboardingCoordinatorDidFinish(_ coordinator: OnboardingCoordinator) {
    appDependency.userDataStore.hasShownExchangeOnboarding = true
    onDidRequestShowQuestionnary?()
  }
}

// MARK: - QuestionnaireCoordinatorDelegate
extension ExchangeCoordinator: QuestionnaireCoordinatorDelegate {
  func questionnaireCoordinator(_ coordinator: QuestionnaireCoordinator,
                                didCreateBasketWith basketID: String,
                                for productDetails: ProductDetails) {
    showCreateLeasingApplicationScreen(with: basketID, for: productDetails)
  }
}

// MARK: - ExchangeInfoViewControllerDelegate

extension ExchangeCoordinator: ExchangeReturnViewControllerDelegate {
  func exchangeReturnViewControllerDidFinish(_ viewController: ExchangeReturnViewController) {
    onDidRequestPopToStart?()
  }
}

// MARK: - ExchangeInfoViewModelDelegate

extension ExchangeCoordinator: ExchangeReturnViewModelDelegate {
  func exchangeReturnViewModel(_ viewModel: ExchangeReturnViewModel,
                               didRequestDiagnosticFor contract: LeasingEntity) {
    showDiagnosticOrContinue(with: contract)
  }
  
  func exchangeReturnViewModel(_ viewModel: ExchangeReturnViewModel,
                               didRequestToShowWebViewWith url: URL) {
    showWebView(url: url)
  }
  
  func exchangeReturnViewModel(_ viewModel: ExchangeReturnViewModel,
                               didRequestToSelectStoreFor contract: LeasingEntity) {
    showStorePoints(with: contract,
                    storePoint: contract.contractActionInfo?.storePoint)
  }
  
  func exchangeReturnViewModelDidCancelContract(_ viewModel: ExchangeReturnViewModel) {
    onDidRequestPopToStart?()
  }
  
  func exchangeReturnViewModel(_ viewModel: ExchangeReturnViewModel,
                               didRequestPaymentWith url: URL) {
    showPayment(with: url)
  }
  
  func exchangeReturnViewModelDidFinish(_ viewModel: ExchangeReturnViewModel) {
    onDidRequestPopToStart?()
  }
}

// MARK: - CreateApplicationCoordinatorDelegate
extension ExchangeCoordinator: CreateApplicationCoordinatorDelegate {
  func createApplicationCoordinator(_ coordinator: CreateApplicationCoordinator, didSign contract: LeasingEntity) {
    showExchangeInfoScreen(applicationID: contract.applicationID)
  }
  
  func createApplicationCoordinatorDidRequestToPopToProfile(_ coordinator: CreateApplicationCoordinator) {
    onDidRequestPopToStart?()
  }
}

// MARK: - StorePointsCoordinatorDelegate
extension ExchangeCoordinator: StorePointsCoordinatorDelegate {
  func storePointsCoordinatorDidRequestClose(_ coordinator: StorePointsCoordinator) {
    navigationController.popViewController(animated: true)
  }
  
  func storePointsCoordinator(_ coordinator: StorePointsCoordinator,
                              didFinishWithSelectedStorePoint storePoint: StorePointInfo) {
    navigationController.popViewController(animated: true)
    onDidRequestUpdateStorePoint?(storePoint)
    onDidRequestUpdateExchangeInfo?()
  }
  
}

// MARK: - ContractDetailsCoordinatorDelegate
extension ExchangeCoordinator: ContractDetailsCoordinatorDelegate {
  func contractDetailsCoordinatorDidFinish(_ coordinator: ContractDetailsCoordinator) {
    onDidRequestPopToStart?()
  }
}

// MARK: - PaymentCoordinatorDelegate
extension ExchangeCoordinator: PaymentCoordinatorDelegate {
  func paymentCoordinatorDidFinish(_ coordinator: PaymentCoordinator) {
    popToController(ExchangeReturnViewController.self)
    onDidRequestUpdateExchangeInfo?()
  }
  
  func paymentCoordinatorDidRequestRepeatPayment(_ coordinator: PaymentCoordinator) {
    popToController(ExchangeReturnViewController.self)
    onDidRequestUpdateExchangeInfo?()
  }
  
  func paymentCoordinatorDidRequestCheckLater(_ coordinator: PaymentCoordinator) {
    onDidRequestPopToStart?()
  }
  
}
