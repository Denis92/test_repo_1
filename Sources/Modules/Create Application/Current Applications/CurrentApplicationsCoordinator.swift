//
//  CurrentApplicationsCoordinator.swift
//  ForwardLeasing
//

import Foundation

struct ApplicationCreationData {
  let leasingType: LeasingApplicationType
  let productName: String?
  let basketID: String
  let previousApplicationID: String?
}

enum CurrentApplicationsFlow {
  case hasCurrentApplication(applications: [LeasingEntity])
  case hasNoCurrentApplication(applications: [LeasingEntity], applicationCreationInfo: ApplicationCreationInfo)
  case updateClientData(applications: [LeasingEntity], activeApplicationData: (LeasingEntity, ClientPersonalData))
}

protocol CurrentApplicationsCoordinatorDelegate: class {
  func currentApplicationsCoordinator(_ coordinator: CurrentApplicationsCoordinator,
                                      didRequestToContinueWith application: LeasingEntity)
  func currentApplicationsCoordinator(_ coordinator: CurrentApplicationsCoordinator,
                                      didRequestToFinishWith application: LeasingEntity)
  func currentApplicationsCoordinator(_ coordinator: CurrentApplicationsCoordinator,
                                      didRequestToContinueOTPFlowWith application: LeasingEntity)
  func currentApplicationsCoordinatorDidEncounterCriticalError(_ coordinator: CurrentApplicationsCoordinator)
  func currentApplicationsCoordinatorDidRequestFinishFlow(_ coordinator: CurrentApplicationsCoordinator)
}

struct CurrentApplicationsCoordinatorConfiguration {
  let flow: CurrentApplicationsFlow
  let isUpgrade: Bool
}

class CurrentApplicationsCoordinator: ConfigurableNavigationFlowCoordinator {
  typealias Configuration = CurrentApplicationsCoordinatorConfiguration
  
  // MARK: - Properties
  
  weak var delegate: CurrentApplicationsCoordinatorDelegate?
  
  let appDependency: AppDependency
  let navigationObserver: NavigationObserver
  let navigationController: NavigationController
  var childCoordinators: [BaseCoordinator] = []
  var onDidFinish: (() -> Void)?
  
  private let flow: CurrentApplicationsFlow
  private let isUpgrade: Bool
  
  // MARK: - Init
  
  required init(appDependency: AppDependency,
                navigationController: NavigationController,
                navigationObserver: NavigationObserver,
                configuration: Configuration) {
    self.navigationController = navigationController
    self.navigationObserver = navigationObserver
    self.appDependency = appDependency
    self.flow = configuration.flow
    self.isUpgrade = configuration.isUpgrade
  }
  
  // MARK: - Navigation
  
  func start(animated: Bool) {
    showCurrentApplicationsScreen(animated: animated)
  }
  
  private func showCurrentApplicationsScreen(animated: Bool) {
    let viewModel = CurrentApplicationsViewModel(flow: flow,
                                                 isUpgrade: isUpgrade,
                                                 dependencies: appDependency)
    viewModel.delegate = self
    let viewController = CurrentApplicationsViewController(viewModel: viewModel)
    viewController.delegate = self
    navigationController.pushViewController(viewController, animated: true)
    navigationObserver.addObserver(self, forPopOf: viewController)
  }
}

// MARK: - CurrentApplicationsViewControllerDelegate

extension CurrentApplicationsCoordinator: CurrentApplicationsViewControllerDelegate {
  func currentApplicationsViewControllerDidFinish(_ viewController: CurrentApplicationsViewController) {
    delegate?.currentApplicationsCoordinatorDidRequestFinishFlow(self)
  }
}

// MARK: - CurrentApplicationsViewModelDelegate

extension CurrentApplicationsCoordinator: CurrentApplicationsViewModelDelegate {
  func currentApplicationsViewModel(_ viewModel: CurrentApplicationsViewModel,
                                    didRequestToContinueWith application: LeasingEntity) {
    delegate?.currentApplicationsCoordinator(self, didRequestToContinueWith: application)
  }

  func currentApplicationsViewModel(_ viewModel: CurrentApplicationsViewModel,
                                    didRequestToContinueOTPFlowWith application: LeasingEntity) {
    if !application.hasPersonalDataExist || isUpgrade {
      delegate?.currentApplicationsCoordinator(self, didRequestToContinueOTPFlowWith: application)
    } else {
      delegate?.currentApplicationsCoordinator(self, didRequestToFinishWith: application)
    }
  }

  func currentApplicationsViewModelDidEncounterCriticalError(_ viewModel: CurrentApplicationsViewModel) {
    delegate?.currentApplicationsCoordinatorDidEncounterCriticalError(self)
  }

  func currentApplicationsViewModel(_ viewModel: CurrentApplicationsViewModel,
                                    didRequestToFinishWith application: LeasingEntity) {
    delegate?.currentApplicationsCoordinator(self, didRequestToFinishWith: application)
  }
}
