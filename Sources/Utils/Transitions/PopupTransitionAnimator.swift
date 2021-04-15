//
//  PopupTransitionAnimator.swift
//  ForwardLeasing
//

import UIKit

class PopupTransitionAnimator: NSObject {
  struct TransitionConfiguration {
    let damping: CGFloat
    let velocity: CGFloat
    let overlayColor: UIColor?
    let animationDuration: TimeInterval

    init(damping: CGFloat = 0.7,
         velocity: CGFloat = 0.6,
         overlayColor: UIColor? = UIColor.base1.withAlphaComponent(0.8),
         animationDuration: TimeInterval = 0.5) {
      self.damping = damping
      self.velocity = velocity
      self.overlayColor = overlayColor
      self.animationDuration = animationDuration
    }
  }

  enum TransitionType {
    case presenting, dismissing
  }

  // MARK: - Properties

  var transitionType: TransitionType
  private let configuration: TransitionConfiguration
  private lazy var overlayView: UIView = {
    let view = UIView()
    view.backgroundColor = configuration.overlayColor
    return view
  }()

  // MARK: - Init

  init(configuration: TransitionConfiguration, transitionType: TransitionType = .presenting) {
    self.transitionType = transitionType
    self.configuration = configuration
    super.init()
  }
}

// MARK: - UIViewControllerAnimatedTransitioning
extension PopupTransitionAnimator: UIViewControllerAnimatedTransitioning {
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return configuration.animationDuration
  }

  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    guard let fromVC = transitionContext.viewController(forKey: .from),
      let toVC = transitionContext.viewController(forKey: .to) else {
        return
    }

    let containerView = transitionContext.containerView
    containerView.backgroundColor = .clear
    let startFrame: CGRect
    let finalFrame: CGRect
    let finalSize = fromVC.view.bounds.size
    switch transitionType {
    case .presenting:
      overlayView.frame = transitionContext.finalFrame(for: fromVC)
      overlayView.alpha = 0
      containerView.addSubview(overlayView)
      containerView.addSubview(toVC.view)
      finalFrame = CGRect(origin: .zero, size: finalSize)
      startFrame = CGRect(origin: CGPoint(x: 0, y: fromVC.view.bounds.height), size: finalSize)
      toVC.view.frame = startFrame
    case .dismissing:
      finalFrame = CGRect(origin: CGPoint(x: 0, y: fromVC.view.bounds.height), size: finalSize)
      startFrame = toVC.view.bounds
      fromVC.view.frame = startFrame
    }
    let options: UIView.AnimationOptions = transitionType == .presenting ? [] : [.beginFromCurrentState]
    UIView
      .animate(withDuration: configuration.animationDuration,
               delay: 0,
               usingSpringWithDamping: configuration.damping,
               initialSpringVelocity: configuration.velocity,
               options: options,
               animations: {
                switch self.transitionType {
                case .presenting:
                  self.overlayView.alpha = 1
                  toVC.view.frame = finalFrame
                case .dismissing:
                  self.overlayView.alpha = 0
                  fromVC.view.frame = finalFrame
                }
      },
               completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
      })
  }
}
