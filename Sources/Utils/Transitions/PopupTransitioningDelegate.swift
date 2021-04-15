//
//  PopupTransitioningDelegate.swift
//  ForwardLeasing
//

import UIKit

class PopupTransitioningDelegate: NSObject {
  // MARK: - Properties
  private let animator = PopupTransitionAnimator(configuration: PopupTransitionAnimator.TransitionConfiguration())
}

// MARK: - UIViewControllerTransitioningDelegate
extension PopupTransitioningDelegate: UIViewControllerTransitioningDelegate {
  func animationController(forPresented presented: UIViewController,
                           presenting: UIViewController,
                           source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    animator.transitionType = .presenting
    return animator
  }

  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    animator.transitionType = .dismissing
    return animator
  }
}
