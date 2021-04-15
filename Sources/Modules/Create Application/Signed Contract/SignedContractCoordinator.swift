//
//  SignedContractCoordinator.swift
//  ForwardLeasing
//

import Foundation

struct SignedContractCoordinatorConfiguration {
  let application: LeasingEntity
  let storePointInfo: StorePointInfo?
}

protocol SignedContractCoordinatorDelegate: class {
  func signedContractCoordinatorDidRequestToClose(_ coordinator: SignedContractCoordinator)
  func signedContractCoordinator(_ coordinator: SignedContractCoordinator,
                                 didFinishWithContract contract: LeasingEntity)
  func signedContractCoordinator(_ coordinator: SignedContractCoordinator,
                                 didRequestToSelectOtherStoreWith application: LeasingEntity)
}

class SignedContractCoordinator: ConfigurableNavigationFlowCoordinator {
  typealias Configuration = SignedContractCoordinatorConfiguration
  // MARK: - Properties
  
  weak var delegate: SignedContractCoordinatorDelegate?
  
  let appDependency: AppDependency
  let navigationObserver: NavigationObserver
  let navigationController: NavigationController
  var childCoordinators: [BaseCoordinator] = []
  var onDidFinish: (() -> Void)?
  var onDidSignedContract: (() -> Void)?
  var onDidSelectStore: ((StorePointInfo?) -> Void)?
  
  private let configuration: SignedContractCoordinatorConfiguration
  
  // MARK: - Init
  
  required init(appDependency: AppDependency,
                navigationController: NavigationController,
                navigationObserver: NavigationObserver,
                configuration: Configuration) {
    self.navigationController = navigationController
    self.navigationObserver = navigationObserver
    self.appDependency = appDependency
    self.configuration = configuration
  }
  
  // MARK: - Navigation
  
  func start(animated: Bool) {
    showSignedContractScreen(animated: animated)
  }
  
  // MARK: - Navigation
  
  private func showSignedContractScreen(animated: Bool) {
    let viewModel = SignedContractViewModel(application: configuration.application,
                                            dependencies: appDependency,
                                            storePointInfo: configuration.storePointInfo)
    viewModel.delegate = self
    onDidSignedContract = { [weak viewModel] in
      viewModel?.loadData()
    }
    onDidSelectStore = { [weak viewModel] storePoint in
      viewModel?.updateStorePoint(storePoint)
    }
    let viewController = SignedContractViewController(viewModel: viewModel)
    viewController.delegate = self
    navigationController.pushViewController(viewController, animated: true)
  }

  private func showConfirmWithSMSScreen(contract: LeasingEntity) {
    let viewModel = PhoneConfirmationViewModel(dependencies: appDependency,
                                               strategyType: .signDelivery(dependency: appDependency,
                                                                           leasingApplication: contract),
                                               showWrogCodeErrorAsAlert: true)
    viewModel.delegate = self
    let viewController = PhoneConfirmationViewController(viewModel: viewModel)
    viewController.delegate = self
    navigationController.pushViewController(viewController, animated: true)
  }

  private func showContractDetails(with contract: LeasingEntity) {
    let configuration = ContractDetailsCoordinatorConfiguration(applicationID: contract.applicationID)
    let coordinator = show(ContractDetailsCoordinator.self, configuration: configuration, animated: true)
    coordinator.delegate = self
  }

  private func showWebViewScreen(url: URL?) {
    guard let url = url else { return }
    let viewController = WebViewController(url: url, token: appDependency.tokenStorage.accessToken)
    navigationController.pushViewController(viewController, animated: true)
  }

  private func showConfirmWithSMSScreen(with contract: LeasingEntity) {
    let viewModel = PhoneConfirmationViewModel(dependencies: appDependency,
                                               strategyType: .leasingContract(dependency: appDependency,
                                                                              leasingApplication: contract),
                                               showWrogCodeErrorAsAlert: true)
    viewModel.delegate = self
    let viewController = PhoneConfirmationViewController(viewModel: viewModel)
    viewController.delegate = self
    navigationController.pushViewController(viewController, animated: true)
  }
  
  private func showStorePoints(with leasingEntity: LeasingEntity,
                               storePoint: StorePointInfo?) {
    let configuration = StorePointsCoordinatorConfiguration(leasingEntity: leasingEntity,
                                                            storePoint: storePoint)
    let coordinator = show(StorePointsCoordinator.self, configuration: configuration, animated: true)
    coordinator.delegate = self
  }


}

// MARK: - SignedContractViewControllerDelegate

extension SignedContractCoordinator: SignedContractViewControllerDelegate {
  func signedContractViewControllerDidFinish(_ viewController: SignedContractViewController) {
    delegate?.signedContractCoordinatorDidRequestToClose(self)
  }
}

// MARK: - SignedContractViewModelDelegate

extension SignedContractCoordinator: SignedContractViewModelDelegate {
  func signedContractViewModel(_ viewModel: SignedContractViewModel,
                               didRequestToOpenWebViewWithURL url: URL?) {
    showWebViewScreen(url: url)
  }

  func signedContractViewModel(_ viewModel: SignedContractViewModel, didFinishPickUpFor contract: LeasingEntity) {
    delegate?.signedContractCoordinator(self, didFinishWithContract: contract)
  }

  func signedContractViewModel(_ viewModel: SignedContractViewModel, didFinishSignDeliveryFor contract: LeasingEntity) {
    showContractDetails(with: contract)
  }

  func signedContractViewModel(_ viewModel: SignedContractViewModel,
                               didRequestToSignDeliveryAgreementFor contract: LeasingEntity) {
    showConfirmWithSMSScreen(contract: contract)
  }
  
  func signedContractViewModel(_ viewModel: SignedContractViewModel,
                               didRequestToSelectOtherStoreWith application: LeasingEntity) {
    showStorePoints(with: application, storePoint: application.contractActionInfo?.storePoint)
//    delegate?.signedContractCoordinator(self, didRequestToSelectOtherStoreWith: application)
  }
  
  func signedContractViewModelDidRequestToCloseScreen(_ viewModel: SignedContractViewModel) {
    delegate?.signedContractCoordinatorDidRequestToClose(self)
  }
}

// MARK: - PhoneConfirmationViewModelDelegate

extension SignedContractCoordinator: PhoneConfirmationViewModelDelegate {
  func phoneConfirmationViewModel(_ viewModel: PhoneConfirmationViewModel,
                                  didFinishWithApplication application: LeasingEntity) {
    navigationController.popViewController(animated: true)
    onDidSignedContract?()
  }
  
  func phoneConfirmationViewModelDidRequestToFinishFlow(_ viewModel: PhoneConfirmationViewModel) {
    delegate?.signedContractCoordinatorDidRequestToClose(self)
  }
}

// MARK: - PhoneConfirmationViewControllerDelegate

extension SignedContractCoordinator: PhoneConfirmationViewControllerDelegate {
  func phoneConfirmationViewControllerDidRequestGoBack(_ viewController: PhoneConfirmationViewController) {
    navigationController.popViewController(animated: true)
  }
}

// MARK: - ContractDetailsCoordinatorDelegate

extension SignedContractCoordinator: ContractDetailsCoordinatorDelegate {
  func contractDetailsCoordinator(_ coordinator: ContractDetailsCoordinator,
                                  didRequestToExchangeProductToModel model: ModelInfo) {
    // do nothing
  }

  func contractDetailsCoordinatorDidFinish(_ coordinator: ContractDetailsCoordinator) {
    delegate?.signedContractCoordinatorDidRequestToClose(self)
  }
}

// MARK: - StorePointsCoordinatorDelegate

extension SignedContractCoordinator: StorePointsCoordinatorDelegate {
  func storePointsCoordinatorDidRequestClose(_ coordinator: StorePointsCoordinator) {
    navigationController.popViewController(animated: true)
  }
  
  func storePointsCoordinator(_ coordinator: StorePointsCoordinator,
                              didFinishWithSelectedStorePoint storePoint: StorePointInfo) {
    onDidSelectStore?(storePoint)
    navigationController.popViewController(animated: true)
  }
  
}
