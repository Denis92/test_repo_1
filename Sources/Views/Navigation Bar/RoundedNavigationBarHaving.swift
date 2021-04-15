//
//  NavigationBarHaving.swift
//  ForwardLeasing
//

import UIKit

enum NavBarScrollType {
  case showOnTopOnly, showOnOffset
}

protocol RoundedNavigationBarHaving: class {
  var scrollType: NavBarScrollType { get }
  var navigationBarView: NavigationBarView { get }
  var scrollView: UIScrollView { get }
  var scrollViewLastOffset: CGFloat { get set }
  func scrollViewDidScroll(_ scrollView: UIScrollView)
}

extension RoundedNavigationBarHaving {
  var scrollType: NavBarScrollType {
    return .showOnTopOnly
  }
  
  func handleScrollDefault(scrollView: UIScrollView) {
    let minOffsetTrigger: CGFloat = 40
    let contentHeight = scrollView.contentSize.height

    navigationBarView.updateToDraggingState(offsetY: scrollView.contentOffset.y + scrollView.contentInset.top,
                                            isTracking: scrollView.isTracking)
    
    switch scrollType {
    case .showOnTopOnly:
      if scrollView.contentOffset.y + scrollView.contentInset.top <= minOffsetTrigger,
         navigationBarView.isCollapsed {
        navigationBarView.setState(isCollapsed: false,
                                   animated: true)
        return
      }

      if scrollView.contentOffset.y + scrollView.contentInset.top > minOffsetTrigger,
         !navigationBarView.isCollapsed {
        navigationBarView.setState(isCollapsed: true,
                                   animated: true)
        return
      }
    case .showOnOffset:
      guard scrollView.contentOffset.y > 0, scrollView.contentOffset.y < contentHeight - scrollView.bounds.height else {
        return
      }

      if abs(scrollView.contentOffset.y - scrollViewLastOffset) > minOffsetTrigger {
        navigationBarView.setState(isCollapsed: scrollView.contentOffset.y > scrollViewLastOffset,
                                   animated: true)
        scrollViewLastOffset = scrollView.contentOffset.y
      }
    }
  }
}
