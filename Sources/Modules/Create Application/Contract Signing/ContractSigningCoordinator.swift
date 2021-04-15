//
//  ContractSigningCoordinator.swift
//  ForwardLeasing
//

import Foundation

struct ContractSigningCoordinatorConfiguration {
  let application: LeasingEntity
}

protocol ContractSigningCoordinatorDelegate: class {
  func contractSigningCoordinatorDidSignContract(_ coordinator: ContractSigningCoordinator, with application: LeasingEntity)
  func contractSigningCoordinatorDidFinish(_ coordinator: ContractSigningCoordinator)
}

class ContractSigningCoordinator: ConfigurableNavigationFlowCoordinator {
  typealias Configuration = ContractSigningCoordinatorConfiguration
  
  // MARK: - Properties
  
  weak var delegate: ContractSigningCoordinatorDelegate?
  
  let appDependency: AppDependency
  let navigationObserver: NavigationObserver
  let navigationController: NavigationController
  var childCoordinators: [BaseCoordinator] = []
  var onDidFinish: (() -> Void)?
  
  private let application: LeasingEntity
  
  // MARK: - Init
  
  required init(appDependency: AppDependency,
                navigationController: NavigationController,
                navigationObserver: NavigationObserver,
                configuration: Configuration) {
    self.navigationController = navigationController
    self.navigationObserver = navigationObserver
    self.appDependency = appDependency
    self.application = configuration.application
  }
  
  // MARK: - Navigation
  
  func start(animated: Bool) {
    showContractSigningScreen(animated: animated)
  }
  
  private func showContractSigningScreen(animated: Bool) {
    let viewModel = ContractSigningViewModel(application: application, dependencies: appDependency)
    viewModel.delegate = self
    let viewController = ContractSigningViewController(viewModel: viewModel)
    viewController.delegate = self
    navigationController.pushViewController(viewController, animated: true)
    navigationObserver.addObserver(self, forPopOf: viewController)
  }
  
  private func showWebViewScreen(for url: URL) {
    let viewController = WebViewController(url: url, token: appDependency.tokenStorage.accessToken)
    navigationController.pushViewController(viewController, animated: true)
  }
  
  private func showConfirmWithSMSScreen(with leasingEntity: LeasingEntity) {
    let viewModel = PhoneConfirmationViewModel(dependencies: appDependency,
                                               strategyType: .leasingContract(dependency: appDependency,
                                                                              leasingApplication: leasingEntity),
                                               showWrogCodeErrorAsAlert: true)
    viewModel.delegate = self
    let viewController = PhoneConfirmationViewController(viewModel: viewModel)
    viewController.delegate = self
    navigationController.pushViewController(viewController, animated: true)
  }
  
  private func showSuccessScreen(with application: LeasingEntity) {
    let successType = SuccessViewControllerType.success(title: R.string.contractSigning.smsSigningSuccessTitle())
    let viewController = SuccessViewController(type: successType) { [weak self] in
      guard let self = self else { return }
      self.delegate?.contractSigningCoordinatorDidSignContract(self, with: application)
    }
    navigationController.pushViewController(viewController, animated: false)
  }
}

// MARK: - SigningViewControllerDelegate

extension ContractSigningCoordinator: ContractSigningViewControllerDelegate {
  func contractSigningViewControllerDidFinish(_ viewController: ContractSigningViewController) {
    delegate?.contractSigningCoordinatorDidFinish(self)
  }
}

// MARK: - ContractSigningViewModelDelegate

extension ContractSigningCoordinator: ContractSigningViewModelDelegate {
  func contractSigningViewModel(_ viewModel: ContractSigningViewModel, didRequestToOpen url: URL) {
    showWebViewScreen(for: url)
  }

  func contractSigningViewModel(_ viewModel: ContractSigningViewModel,
                                didRequestToSignWithSMS leasingEntity: LeasingEntity) {
    showConfirmWithSMSScreen(with: leasingEntity)
  }
}

// MARK: - PhoneConfirmationViewControllerDelegate

extension ContractSigningCoordinator: PhoneConfirmationViewControllerDelegate {
  func phoneConfirmationViewControllerDidRequestGoBack(_ viewController: PhoneConfirmationViewController) {
    navigationController.popViewController(animated: true)
  }
}

// MARK: - PhoneConfirmationViewModelDelegate

extension ContractSigningCoordinator: PhoneConfirmationViewModelDelegate {
  func phoneConfirmationViewModel(_ viewModel: PhoneConfirmationViewModel,
                                  didFinishWithApplication application: LeasingEntity) {
    showSuccessScreen(with: application)
  }
  
  func phoneConfirmationViewModelDidRequestToFinishFlow(_ viewModel: PhoneConfirmationViewModel) {
    delegate?.contractSigningCoordinatorDidFinish(self)
  }
}
