//
//  UIScrollView+BottomSheetViewController.swift
//  ForwardLeasing
//

import UIKit

extension UIScrollView {
  func addObserver(to viewController: BottomSheetViewController) {
    viewController.updateScrollView(scrollView: self)
  }
  
  func removeObserver(from viewController: BottomSheetViewController) {
    viewController.updateScrollView(scrollView: nil)
  }
}
