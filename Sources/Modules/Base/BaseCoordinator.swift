//
//  BaseCoordinator.swift
//  ForwardLeasing
//

import UIKit

protocol BaseCoordinator: class {
  var topController: UIViewController { get }
  var childCoordinators: [BaseCoordinator] { get set }
  var onDidFinish: (() -> Void)? { get set }
  var topCoordinator: BaseCoordinator? { get }
  
  var appDependency: AppDependency { get }
  var presentingController: UIViewController { get }
  
  func start(animated: Bool)
}

extension BaseCoordinator {
  var topCoordinator: BaseCoordinator? {
    return childCoordinators.last?.topCoordinator ?? childCoordinators.last
  }
}

extension BaseCoordinator {
  func remove(child coordinator: BaseCoordinator) {
    if let index = childCoordinators.firstIndex(where: { $0 === coordinator }) {
      childCoordinators.remove(at: index)
    }
  }
  
  func add(child coordinator: BaseCoordinator) {
    coordinator.onDidFinish = { [weak self, weak coordinator] in
      guard let coordinator = coordinator else { return }
      self?.remove(child: coordinator)
    }
    childCoordinators.append(coordinator)
  }
}
