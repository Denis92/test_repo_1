//
//  ActivityIndicatorTransiotioningDelegate.swift
//  ForwardLeasing
//

import UIKit

private extension Constants {
  static let presentTransitionDuration: TimeInterval = 0.3
  static let dismissTransitionDuration: TimeInterval = 0.3
}

class ActivityIndicatorTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
  func animationController(forPresented presented: UIViewController,
                           presenting: UIViewController,
                           source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return ActivityIndicatorPresentedTransitioning()
  }
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return ActivityIndicatorDismissTransitioning()
  }
}

class ActivityIndicatorPresentedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return Constants.presentTransitionDuration
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    guard let presentingView = transitionContext.view(forKey: .to) else { return }
    let containerView = transitionContext.containerView
    presentingView.frame = containerView.frame
    presentingView.layoutIfNeeded()
    containerView.addSubview(presentingView)
    
    presentingView.backgroundColor = .clear
    UIView.animate(withDuration: 0.5,
                   animations: {
      presentingView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
      presentingView.subviews.forEach {
        $0.transform = .identity
      }
    }, completion: { _ in
      transitionContext.completeTransition(true)
    })
  }
}

class ActivityIndicatorDismissTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return Constants.dismissTransitionDuration
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    guard let dismissingView = transitionContext.view(forKey: .from) else { return }
    
    UIView.animate(withDuration: 0.5, animations: {
      dismissingView.backgroundColor = .clear
    }, completion: { _ in
      transitionContext.completeTransition(true)
    })
  }
}
