//
//  SendingApplicationCoordinator.swift
//  ForwardLeasing
//

import Foundation

protocol SendingApplicationCoordinatorDelegate: class {
  func sendingApplicationCoordinator(_ coordinator: SendingApplicationCoordinator,
                                     didFinishWithApplication application: LeasingEntity)
  func sendingApplicationCoordinatorDidRequestCheckLater(_ coordinator: SendingApplicationCoordinator)
  func sendingApplicationCoordinatorDidCancel(_ coordinator: SendingApplicationCoordinator)
  func sendingApplicationCoordinatorDidRequestClose(_ coordinator: SendingApplicationCoordinator)
}

struct SendingApplicationCoordinatorConfig {
  let application: LeasingEntity
}

class SendingApplicationCoordinator: ConfigurableNavigationFlowCoordinator {
  typealias Configuration = SendingApplicationCoordinatorConfig
  
  // MARK: - Properties
  weak var delegate: SendingApplicationCoordinatorDelegate?
  var navigationObserver: NavigationObserver
  var navigationController: NavigationController
  var childCoordinators: [BaseCoordinator] = []
  var onDidFinish: (() -> Void)?
  var appDependency: AppDependency
  var configuration: Configuration
  
  // MARK: - Init
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
    showSendingApplication()
  }
  
  private func showSendingApplication() {
    let viewModel = SendingApplicationViewModel(dependencies: appDependency, application: configuration.application)
    viewModel.delegate = self
    let viewController = SendingApplicationViewController(viewModel: viewModel)
    navigationController.pushViewController(viewController, animated: true)
  }
}

extension SendingApplicationCoordinator: SendingApplicationViewModelDelegate {
  func sendingApplicationViewModelDidRequestClose(_ viewModel: SendingApplicationViewModel) {
    delegate?.sendingApplicationCoordinatorDidRequestClose(self)
  }
  
  func sendingApplicationViewModelDidRequestCheckLater(_ viewModel: SendingApplicationViewModel) {
    delegate?.sendingApplicationCoordinatorDidRequestCheckLater(self)
  }
  
  func sendingApplicationViewModelDidCancelApplication(_ viewModel: SendingApplicationViewModel) {
    delegate?.sendingApplicationCoordinatorDidCancel(self)
  }
  
  func sendingApplicationViewModel(_ viewModel: SendingApplicationViewModel,
                                   didFinishWithApplication application: LeasingEntity) {
    delegate?.sendingApplicationCoordinator(self, didFinishWithApplication: application)
  }
}
