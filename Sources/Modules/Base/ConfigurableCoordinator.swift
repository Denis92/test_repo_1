//
//  ConfigurableCoordinator.swift
//  ForwardLeasing
//

import UIKit

protocol HasConfiguration {
  associatedtype Configuration
}

protocol ConfigurableCoordinator: BaseCoordinator, HasConfiguration {
  init(appDependency: AppDependency, presentingViewController: UIViewController, configuration: Configuration)
}

protocol ConfigurableNavigationFlowCoordinator: NavigationFlowCoordinator, HasConfiguration {
  init(appDependency: AppDependency,
       navigationController: NavigationController,
       navigationObserver: NavigationObserver,
       configuration: Configuration)
  
  func popToController<T: UIViewController>(_ type: T.Type)
}

extension ConfigurableNavigationFlowCoordinator {
  func popToController<T: UIViewController>(_ type: T.Type) {
    if let viewController = navigationController.viewControllers.first(where: { $0 is T }) {
      if #available(iOS 14, *), let firstIndex = navigationController.viewControllers.firstIndex(where: { $0 is T }) {
        for index in (firstIndex + 1)..<navigationController.viewControllers.count {
          navigationController.viewControllers.element(at: index)?.hidesBottomBarWhenPushed = false
        }
      }
      navigationController.popToViewController(viewController, animated: true)
    }
  }
}

extension BaseCoordinator {
  @discardableResult
  func present<Coordinator: ConfigurableCoordinator, Configuration>(_ type: Coordinator.Type,
                                                                    configuration: Configuration,
                                                                    animated: Bool) -> Coordinator
    where Configuration == Coordinator.Configuration {
    let coordinator = Coordinator(appDependency: appDependency,
                                  presentingViewController: presentingController,
                                  configuration: configuration)
    add(child: coordinator)
    coordinator.start(animated: animated)
    return coordinator
  }
  
  @discardableResult
  func present<Coordinator: ConfigurableNavigationFlowCoordinator, Configuration>(_ type: Coordinator.Type,
                                                                                  configuration: Configuration,
                                                                                  animated: Bool) -> Coordinator
    where Configuration == Coordinator.Configuration {
    let navigationController = NavigationController()
    let navigationObserver = NavigationObserver(navigationController: navigationController)
    let coordinator = Coordinator(appDependency: appDependency,
                                  navigationController: navigationController,
                                  navigationObserver: navigationObserver,
                                  configuration: configuration)
    add(child: coordinator)
    coordinator.start(animated: animated)
    return coordinator
  }
}

extension NavigationFlowCoordinator {
  @discardableResult
  func show<Coordinator: ConfigurableNavigationFlowCoordinator, Configuration>(_ type: Coordinator.Type,
                                                                               configuration: Configuration,
                                                                               animated: Bool) -> Coordinator
    where Configuration == Coordinator.Configuration {
    let coordinator = Coordinator(appDependency: appDependency,
                                  navigationController: navigationController,
                                  navigationObserver: navigationObserver,
                                  configuration: configuration)
    add(child: coordinator)
    coordinator.start(animated: animated)
    return coordinator
  }
}
