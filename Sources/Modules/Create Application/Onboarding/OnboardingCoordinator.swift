//
//  OnboardingCoordinator.swift
//  ForwardLeasing
//

import Foundation

protocol OnboardingCoordinatorDelegate: class {
  func onboardingCoordinatorDidFinish(_ coordinator: OnboardingCoordinator)
}

struct OnboardingCoordinatorConfiguration {
  let type: OnboardingType
}

class OnboardingCoordinator: ConfigurableNavigationFlowCoordinator {
  typealias Configuration = OnboardingCoordinatorConfiguration
  // MARK: - Properties
  var navigationObserver: NavigationObserver
  weak var delegate: OnboardingCoordinatorDelegate?
  var navigationController: NavigationController
  var childCoordinators: [BaseCoordinator] = []
  var onDidFinish: (() -> Void)?
  var appDependency: AppDependency
  
  private let configuration: Configuration
  
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
  
  // MARK: - Init
  func start(animated: Bool) {
    showOnboarding()
  }
  
  private func showOnboarding() {
    let viewModel = OnboardingViewModel(type: configuration.type)
    viewModel.delegate = self
    let viewController = OnboardingViewController(viewModel: viewModel)
    navigationController.pushViewController(viewController, animated: true)
    navigationObserver.addObserver(self, forPopOf: viewController)
  }
}

// MARK: - OnboardingViewModelDelegate

extension OnboardingCoordinator: OnboardingViewModelDelegate {
  func onboardingViewModelDidFinish(_ viewModel: OnboardingViewModel) {
    delegate?.onboardingCoordinatorDidFinish(self)
  }
  
  func onboardingViewModelDidRequestToClose(_ viewModel: OnboardingViewModel) {
    navigationController.popViewController(animated: true)
  }
}
