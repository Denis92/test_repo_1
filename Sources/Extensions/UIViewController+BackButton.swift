//
//  UIViewController+BackButton.swift
//  ForwardLeasing
//

import UIKit

extension UIViewController {
  func setDefaultBackButtonTitle() {
    if #available(iOS 14.0, *) {
      navigationItem.backButtonDisplayMode = .minimal
    } else {
      navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
  }
}
