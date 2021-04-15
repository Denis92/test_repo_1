//
//  UINavigationController+PreviousShown.swift
//  ForwardLeasing
//

import UIKit

extension UINavigationController {
  var poppedViewController: UIViewController? {
    guard let fromViewController = transitionCoordinator?.viewController(forKey: .from),
      !viewControllers.contains(fromViewController) else {
        return nil
    }
    return fromViewController
  }
}
