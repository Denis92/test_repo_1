//
//  NavigationFlowCoordinator.swift
//  ForwardLeasing
//

import UIKit

protocol NavigationFlowCoordinator: BaseCoordinator, NavigationPopObserver {
  var navigationController: NavigationController { get }
  var navigationObserver: NavigationObserver { get }
}

extension NavigationFlowCoordinator {
  var topController: UIViewController {
    if let lastChild = topCoordinator {
      return lastChild.topController
    }
    var presentedController: UIViewController? = navigationController.presentedViewController
    
    while let presentedViewController = presentedController?.presentedViewController {
      presentedController = presentedViewController
    }
    
    while presentedController is UIAlertController {
      presentedController = presentedController?.presentingViewController
    }
    
    if let navigationViewController = presentedController as? UINavigationController {
      presentedController = navigationViewController.topViewController
    }
    
    return (presentedController ?? navigationController.topViewController) ?? navigationController
  }
  
  var presentingController: UIViewController {
    return navigationController
  }
}

// MARK: - NavigationPopObserver

extension NavigationFlowCoordinator {
  func navigationObserver(_ observer: NavigationObserver, didObserveViewControllerPop viewController: UIViewController) {
    log.debug("observer: \(observer) did observe pop of \(viewController)")
    onDidFinish?()
  }
}
