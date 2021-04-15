//
//  ProfileCoordinator.swift
//  ForwardLeasing
//

import UIKit

class ProfileCoordinator: ConfigurableNavigationFlowCoordinator {
  typealias Configuration = Void
  // MARK: - Properties
  private let utility: ProfileCoordinatorUtility
  
  let appDependency: AppDependency
  var navigationObserver: NavigationObserver
  let navigationController: NavigationController
  var childCoordinators: [BaseCoordinator] = []
  var onDidFinish: (() -> Void)?
  
  private var onDidFinishPaymentSuccess: (() -> Void)?
  private var onDidUpdateContract: ((LeasingEntity) -> Void)?
  
  // MARK: - Init
  required init(appDependency: AppDependency,
                navigationController: NavigationController,
                navigationObserver: NavigationObserver,
                configuration: Configuration) {
    self.navigationController = navigationController
    self.navigationObserver = navigationObserver
    self.appDependency = appDependency
    utility = ProfileCoordinatorUtility(dependencies: appDependency)
    appDependency.logoutHandler = self
    appDependency.authHandler = self
    appDependency.networkServiceDelegate = self
  }
  
  // MARK: - Navigation
  
  func start(animated: Bool) {
    if !utility.isLoggedIn {
      showAuthorizationScreen(animated: animated)
    } else {
      showProfileScreen(animated: animated)
    }
  }
  
  private func showAuthorizationScreen(animated: Bool) {
    let coordinator = show(AuthCoordinator.self, configuration: (), animated: animated)
    coordinator.delegate = self
  }
  
  private func showProfileScreen(animated: Bool) {
    let viewModel = ProfileViewModel(dependencies: appDependency)
    onDidFinishPaymentSuccess = { [weak viewModel] in
      viewModel?.loadData()
    }
    onDidUpdateContract = { [weak viewModel] contract in
      viewModel?.updateContractIfNeeded(contract)
    }
    viewModel.delegate = self
    let viewController = ProfileViewController(viewModel: viewModel)
    viewController.title = R.string.profile.screenTitle()
    navigationController.pushViewController(viewController, animated: animated)
    navigationObserver.addObserver(self, forPopOf: viewController)
  }
  
  private func showProfileSettings() {
    let flow: ProfileSettingsFlow = appDependency.userDataStore.isLoggedIn ? .authorized : .notAuthorized
    show(ProfileSettingsCoordinator.self, configuration: flow, animated: true)
  }
  
  private func showCreateApplicationScreen(with leasingEntity: LeasingEntity) {
    let configuration = CreateApplicationFlow.continue(application: leasingEntity)
    let coordinator = show(CreateApplicationCoordinator.self, configuration: configuration, animated: true)
    coordinator.delegate = self
  }
  
  private func resetToProfile() {
    let viewModel = ProfileViewModel(dependencies: appDependency)
    viewModel.delegate = self
    let viewController = ProfileViewController(viewModel: viewModel)
    viewController.title = R.string.profile.screenTitle()
    navigationController.setViewControllers([viewController], animated: false)
    navigationObserver.addObserver(self, forPopOf: viewController)
  }
  
  private func resetToAuth() {
    showAuthorizationScreen(animated: false)
    if let viewController = navigationController.viewControllers.last {
      navigationController.setViewControllers([viewController], animated: false)
    }
  }
  
  func showContractDetails(applicationID: String) {
    let configuration = ContractDetailsCoordinatorConfiguration(applicationID: applicationID)
    let coordinator = show(ContractDetailsCoordinator.self,
                           configuration: configuration,
                           animated: true)
    coordinator.delegate = self
  }
  
  private func showSubscriptionContractDetails(subscription: BoughtSubscription) {
    show(SubscriptionContractCoordinator.self, configuration: subscription, animated: true)
  }
  
  private func showCreateApplication(with application: LeasingEntity) {
    let flow: CreateApplicationFlow = .continue(application: application)
    let coordinator = show(CreateApplicationCoordinator.self, configuration: flow, animated: true)
    coordinator.delegate = self
  }
  
  private func showPaymentRegistration(with contract: LeasingEntity) {
    let configuration = PaymentRegistrationCoordinatorConfig(contract: contract)
    let coordinator = show(PaymentRegistrationCoordinator.self, configuration: configuration, animated: true)
    coordinator.delegate = self
  }
  
  private func showBuySubscription(with subscription: BoughtSubscription) {
    let configuration = BuySubscriptionConfiguration(name: subscription.name, subscriptionItemID: subscription.id.description,
                                                     selectedCard: .new, saveCard: false, flow: .profile)
    let coordinator = show(BuySubscriptionCoordinator.self, configuration: configuration,
                           animated: true)
    coordinator.delegate = self
  }
}

// MARK: - NetworkService Delegate

extension ProfileCoordinator: NetworkServiceDelegate {
  func networkServiceDidEncounterUnauthorizedError(_ networkService: NetworkService) {
    logOut()
  }
}

// MARK: - LogoutHandler

extension ProfileCoordinator: LogoutHandler {
  func logOut() {
    utility.logOut {
      self.resetToAuth()
    }
  }
}

// MARK: - AuthHandlerк

extension ProfileCoordinator: AuthHandler {
  func authorize() {
    if !(navigationController.viewControllers.first is ProfileViewController) {
      resetToProfile()
    }
  }
}

// MARK: - ProfileViewModelDelegate

extension ProfileCoordinator: ProfileViewModelDelegate {
  func profileViewModel(_ viewModel: ProfileViewModel,
                        didRequestBuyAgainWithSubscription subscription: BoughtSubscription) {
    showBuySubscription(with: subscription)
  }
  
  func profileViewModelDidRequestShowSettings(_ viewModel: ProfileViewModel) {
    showProfileSettings()
  }

  func profileViewModel(_ viewModel: ProfileViewModel,
                        didRequestToShowDetailsFor leasingEntity: LeasingEntity) {
    showContractDetails(applicationID: leasingEntity.applicationID)
  }

  func profileViewModel(_ viewModel: ProfileViewModel,
                        didRequestShowDetailsFor subscription: BoughtSubscription) {
    showSubscriptionContractDetails(subscription: subscription)
  }
  func profileViewModel(_ viewModel: ProfileViewModel,
                        didRequestContinueCreate leasingEntity: LeasingEntity) {
    showCreateApplicationScreen(with: leasingEntity)
  }
  
  func profileViewModel(_ viewModel: ProfileViewModel, didRequestPayWithContract contract: LeasingEntity) {
    showPaymentRegistration(with: contract)
  }
}

// MARK: - AuthCoordinatorDelegate

extension ProfileCoordinator: AuthCoordinatorDelegate {
  func authCoordinatorDidSignIn(_ coordinator: AuthCoordinator) {
    resetToProfile()
  }
}

// MARK: - CreateApplicationCoordinatorDelegate
extension ProfileCoordinator: CreateApplicationCoordinatorDelegate {
  func createApplicationCoordinator(_ coordinator: CreateApplicationCoordinator, didSign contract: LeasingEntity) {
    // do nothing
  }

  func createApplicationCoordinatorDidRequestToPopToProfile(_ coordinator: CreateApplicationCoordinator) {
    popToController(ProfileViewController.self)
  }
}

// MARK: - ContractDetailsCoordinatorDelegate
extension ProfileCoordinator: ContractDetailsCoordinatorDelegate {
  func contractDetailsCoordinator(_ coordinator: ContractDetailsCoordinator,
                                  didRequestUpdateContract contract: LeasingEntity) {
    onDidUpdateContract?(contract)
  }

  func contractDetailsCoordinatorDidFinish(_ coordinator: ContractDetailsCoordinator) {
    popToController(ProfileViewController.self)
  }
}

// MARK: - PaymentRegistrationCoordinatorDelegate
extension ProfileCoordinator: PaymentRegistrationCoordinatorDelegate {
  func paymentRegistrationCoordinatorDidFinishSuccess(_ coordinator: PaymentRegistrationCoordinator) {
    onDidFinishPaymentSuccess?()
  }
}

// MARK: - BuySubscriptionCoordinatorDelegate
extension ProfileCoordinator: BuySubscriptionCoordinatorDelegate {
  func buySubscriptionCoordinatorDidRequestPopToProfile(_ coordinator: BuySubscriptionCoordinator) {
    popToController(ProfileViewController.self)
  }
}
