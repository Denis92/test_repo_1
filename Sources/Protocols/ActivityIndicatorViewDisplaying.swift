//
//  ActivityIndicatorViewDisplaying.swift
//  ForwardLeasing
//

import UIKit

protocol ActivityIndicatorViewDisplaying {
  var shouldShowActivityIndicator: Bool { get }
  var activityIndicatorView: ActivityIndicatorView { get }
  var activityIndicatorContainerView: UIView { get }

  func addActivityIndicatorView()
}

extension ActivityIndicatorViewDisplaying {
  func addActivityIndicatorView() {
    activityIndicatorContainerView.addSubview(activityIndicatorView)
    activityIndicatorView.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
    activityIndicatorView.isHidden = true
  }
}

extension ActivityIndicatorViewDisplaying where Self: UIViewController {
  var shouldShowActivityIndicator: Bool {
    if let dataReloading = self as? DataReloading & ViewModelBinding {
      return !dataReloading.refreshControl.isRefreshing
    }
    return true
  }

  var activityIndicatorContainerView: UIView {
    return view
  }
}
