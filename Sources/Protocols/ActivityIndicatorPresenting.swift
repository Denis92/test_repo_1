//
//  ActivityIndicatorPresenting.swift
//  ForwardLeasing
//

import UIKit

protocol ActivityIndicatorPresenting: UIViewController {
  func presentActivtiyIndicator(completion: (() -> Void)?)
  func dismissActivityIndicator(completion: (() -> Void)?)
}

extension ActivityIndicatorPresenting {
  func presentActivtiyIndicator(completion: (() -> Void)?) {
    let viewController = ActivityIndicatorController()
    present(viewController, animated: true, completion: completion)
  }
  
  func dismissActivityIndicator(completion: (() -> Void)?) {
    dismiss(animated: true, completion: completion)
  }
}
