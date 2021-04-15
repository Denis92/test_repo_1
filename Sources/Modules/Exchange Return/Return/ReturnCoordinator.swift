//
//  ReturnCoordinator.swift
//  ForwardLeasing
//

import Foundation

struct ReturnCoordinatorConfiguration {
  let contract: LeasingEntity
}

class ReturnCoordinator: ConfigurableNavigationFlowCoordinator {
  typealias Configuration = ReturnCoordinatorConfiguration
  
  // MARK: - Properties
  
  let appDependency: AppDependency
  let navigationObserver: NavigationObserver
  let navigationController: NavigationController
  var childCoordinators: [BaseCoordinator] = []
  var onDidFinish: (() -> Void)?

  private var onDidRequestPopToStart: (() -> Void)?
  private var onDidRequestUpdateExchangeInfo: (() -> Void)?
  private var onDidRequestUpdateStorePoint: ((StorePointInfo) -> Void)?
  private let configuration: ReturnCoordinatorConfiguration

  required init(appDependency: AppDependency,
                navigationController: NavigationController,
                navigationObserver: NavigationObserver,
                configuration: ReturnCoordinatorConfiguration) {
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
    if appDependency.userDataStore.hasShownReturnOnboarding {
      startFlow()
    } else {
      showOnboarding(animated: animated)
    }
  }
  
  // MARK: - Navigation
  private func startFlow() {
    if configuration.contract.status == .returnCreated {
      showReturnInfoScreen(applicationID: configuration.contract.applicationID)
    } else {
      showQuestionnary()
    }
  }

  private func showOnboarding(animated: Bool) {
    let configuration = OnboardingCoordinatorConfiguration(type: .return)
    let coordinator = show(OnboardingCoordinator.self, configuration: configuration, animated: animated)
    coordinator.delegate = self
  }

  private func showQuestionnary() {
    let flow = QuestionnaireFlow.return
    let configuration = QuestionnaireCoordinatorConfiguration(flow: flow,
                                                              contract: self.configuration.contract)
    let coordinator = show(QuestionnaireCoordinator.self, configuration: configuration, animated: true)
    coordinator.delegate = self
  }

  private func showStorePoints(with leasingEntity: LeasingEntity,
                               storePoint: StorePointInfo?) {
    let configuration = StorePointsCoordinatorConfiguration(leasingEntity: leasingEntity,
                                                            storePoint: storePoint)

    let coordinator = show(StorePointsCoordinator.self, configuration: configuration, animated: true)
    coordinator.delegate = self
  }

  private func showReturnInfoScreen(applicationID: String) {
    let cancelStrategy = ReturnCancelStrategy(contractService: appDependency.contractService)
    let input = ReturnViewModelInput(cancelStrategy: cancelStrategy,
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

  private func showDiagnosticOrContinue(with leasingEntity: LeasingEntity) {
    guard let sessionID = leasingEntity.contractActionInfo?.checkSessionID,
          let sessionURL = leasingEntity.contractActionInfo?.checkSessionURL else {
      return
    }
    appDependency.diagnosticService.showDiagnosticOrContinue(with: sessionID, sessionURL: sessionURL).ensure {
      self.onDidRequestPopToStart?()
    }.cauterize()
  }

  private func showWebView(url: URL) {
    let viewController = WebViewController(url: url, token: appDependency.tokenStorage.accessToken)
    navigationController.pushViewController(viewController, animated: true)
  }

  private func showPayment(with url: URL) {
    let configuration = PaymentCoordinatorConfiguration(paymentURL: url)
    let coordinator = show(PaymentCoordinator.self, configuration: configuration, animated: true)
    coordinator.delegate = self
  }

}

// MARK: - OnboardingCoordinatorDelegate

extension ReturnCoordinator: OnboardingCoordinatorDelegate {
  func onboardingCoordinatorDidFinish(_ coordinator: OnboardingCoordinator) {
    appDependency.userDataStore.hasShownReturnOnboarding = true
    showQuestionnary()
  }
}

// MARK: - QuestionnaireCoordinatorDelegate
extension ReturnCoordinator: QuestionnaireCoordinatorDelegate {
  func questionnaireCoordinator(_ coordinator: QuestionnaireCoordinator,
                                didRequestReturn contract: LeasingEntity) {
    showReturnInfoScreen(applicationID: contract.applicationID)
  }
}

extension ReturnCoordinator: StorePointsCoordinatorDelegate {
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

// MARK: - ExchangeInfoViewControllerDelegate

extension ReturnCoordinator: ExchangeReturnViewControllerDelegate {
  func exchangeReturnViewControllerDidFinish(_ viewController: ExchangeReturnViewController) {
    onDidRequestPopToStart?()
  }
}

// MARK: - ExchangeInfoViewModelDelegate

extension ReturnCoordinator: ExchangeReturnViewModelDelegate {
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

// MARK: - PaymentCoordinatorDelegate
extension ReturnCoordinator: PaymentCoordinatorDelegate {
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
