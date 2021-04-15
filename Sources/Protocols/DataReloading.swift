//
//  DataReloading.swift
//  ForwardLeasing
//

import UIKit

protocol DataReloading where Self: UIViewController {
  var refreshControl: UIRefreshControl { get }

  func configureRefreshControl()
}

extension DataReloading {
  func configureRefreshControl() {
    refreshControl.tintColor = .white
    refreshControl.bounds.origin.y = -18
  }
}
