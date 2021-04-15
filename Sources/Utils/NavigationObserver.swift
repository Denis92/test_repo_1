//
//  NavigationObserver.swift
//  ForwardLeasing
//

import UIKit

protocol NavigationPopObserver: class {
  func navigationObserver(_ observer: NavigationObserver,
                          didObserveViewControllerPop viewController: UIViewController)
}

private struct NavigationPopObserverWrapper {
  weak var observer: NavigationPopObserver?
  weak var observedController: UIViewController?
}

class NavigationObserver: NSObject {
  private let navigationController: UINavigationController
  private var observers: [NavigationPopObserverWrapper] = []
  private var shouldStopPopGesture = false
  
  init(navigationController: UINavigationController) {
    self.navigationController = navigationController
    super.init()
    navigationController.delegate = self
    navigationController.interactivePopGestureRecognizer?.delegate = self
  }
  
  func addObserver(_ observer: NavigationPopObserver,
                   forPopOf viewController: UIViewController) {
    observers.append(NavigationPopObserverWrapper(observer: observer, observedController: viewController))
  }

  func pauseRecognizingPopGesture() {
    shouldStopPopGesture = true
  }

  func resumeRecognizingPopGesture() {
    shouldStopPopGesture = true
  }
}

// MARK: - UINavigationControllerDelegate

extension NavigationObserver: UINavigationControllerDelegate {
  func navigationController(_ navigationController: UINavigationController,
                            willShow viewController: UIViewController, animated: Bool) {
    if viewController is NavigationBarHiding {
      navigationController.setNavigationBarHidden(true, animated: animated)
    } else {
      navigationController.setNavigationBarHidden(false, animated: animated)
    }
  }
  
  func navigationController(_ navigationController: UINavigationController,
                            didShow viewController: UIViewController,
                            animated: Bool) {
    guard let poppedViewController = navigationController.poppedViewController else {
      return
    }
    if let (index, observer) = observers.enumerated().first(where: {
        $1.observedController == poppedViewController
      }) {
      
      observer.observer?.navigationObserver(self, didObserveViewControllerPop: poppedViewController)
      observers.remove(at: index)
    }
  }
}

// MARK: - UIGestureRecognizerDelegate

extension NavigationObserver: UIGestureRecognizerDelegate {
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    guard gestureRecognizer == navigationController.interactivePopGestureRecognizer else {
      return true
    }

    guard !shouldStopPopGesture else {
      return false
    }

    return !navigationController.viewControllers.isEmpty
  }
}
