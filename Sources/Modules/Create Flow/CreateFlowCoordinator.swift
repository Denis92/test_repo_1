//
//  CreateFlowCoordinator.swift
//  ForwardLeasing
//

// TODO: - Delete file if no time for refatoring

import Foundation

enum CreateFlow {
  case start(product: LeasingProductInfo, basketID: String)
  case `continue`(application: LeasingEntity)
}

protocol CreateFlowCoordinatorDelegate: class {
  func createApplicationCoordinatorDidRequestToPopToProfile(_ coordinator: CreateApplicationCoordinator)
}

class CreateFlowCoordinator: NSObject, ConfigurableNavigationFlowCoordinator {
  typealias Configuration = CreateFlow
  // MARK: - Properties

  let appDependency: AppDependency
  let navigationObserver: NavigationObserver
  let navigationController: NavigationController
  var childCoordinators: [BaseCoordinator] = []
  var onDidFinish: (() -> Void)?

  weak var delegate: CreateFlowCoordinatorDelegate?

  private let utility: CreateFlowCoordinatorUtility
  private let flow: CreateFlow
  private var leasingEntity: LeasingEntity?
  private var onNeedsToPopToStart: (() -> Void)?
  private var onDidDismissModalController: (() -> Void)?

  // MARK: - Init

  required init(appDependency: AppDependency,
                navigationController: NavigationController,
                navigationObserver: NavigationObserver,
                configuration: Configuration) {
    self.navigationController = navigationController
    self.navigationObserver = navigationObserver
    self.appDependency = appDependency
    self.flow = configuration
    self.utility = CreateFlowCoordinatorUtility(dependencies: appDependency)
  }

  deinit {
    navigationObserver.resumeRecognizingPopGesture()
  }

  // MARK: - Navigation

  func start(animated: Bool) {
    navigationObserver.pauseRecognizingPopGesture()
    let topViewController = navigationController.topViewController
    onNeedsToPopToStart = { [weak self, weak topViewController] in
      guard let navigationController = self?.navigationController, let viewController = topViewController else {
        return
      }
      navigationController.presentedViewController?.dismiss(animated: false, completion: nil)
      navigationController.popToViewController(viewController, animated: true)
    }
    if utility.needsToShowOnboarding {
      showOnboarding(animated: animated)
    } else {
      startFlow(animated: animated)
    }
  }

  private func showOnboarding(animated: Bool) {
    let configuration = OnboardingCoordinatorConfiguration(type: .order)
    let coordinator = show(OnboardingCoordinator.self, configuration: configuration, animated: animated)
    coordinator.delegate = self
    utility.markOnboardingAsShown()
  }


  private func startFlow(animated: Bool) {
    switch flow {
    case .start:
      break
    case .continue(let leasingEntity):
      break
    }
  }

  private func showCreateApplication() {

  }
}

// MARK: - OnboardingCoordinatorDelegate

extension CreateFlowCoordinator: OnboardingCoordinatorDelegate {
  func onboardingCoordinatorDidFinish(_ coordinator: OnboardingCoordinator) {
    startFlow(animated: true)
  }
}
