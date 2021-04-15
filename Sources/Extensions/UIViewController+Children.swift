//
//  UIViewController+Children.swift
//  ForwardLeasing
//

import UIKit

extension UIViewController {
  func addChildViewController(_ viewController: UIViewController, to view: UIView) {
    guard viewController.view.superview == nil else { return }
    addChild(viewController)
    view.addSubview(viewController.view)
    viewController.view.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    viewController.didMove(toParent: self)
  }
  
  func removeChildViewController(_ viewController: UIViewController) {
    guard viewController.view.superview != nil else { return }
    viewController.willMove(toParent: nil)
    viewController.view.removeFromSuperview()
    viewController.removeFromParent()
  }
}
