//
//  ActivityIndicatorEmptyViewPresenting.swift
//  ForwardLeasing
//

import UIKit

protocol ActivityIndicatorEmptyViewPresenting {
  var activityIndicatorContainer: UIView { get }
  var activityIndicator: ActivityIndicatorView { get }
  
  func setupActivityIndicator()
  func showActivityIndicator()
  func hideActivityIndicator()
}

extension ActivityIndicatorEmptyViewPresenting where Self: UIViewController {
  func setupActivityIndicator() {
    activityIndicatorContainer.backgroundColor = .base2
    view.addSubview(activityIndicatorContainer)
    activityIndicatorContainer.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    activityIndicatorContainer.addSubview(activityIndicator)
    activityIndicator.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
    activityIndicator.isAnimating = true
  }
  
  func showActivityIndicator() {
    activityIndicatorContainer.isHidden = false
  }
  
  func hideActivityIndicator() {
    activityIndicatorContainer.isHidden = true
  }
}
