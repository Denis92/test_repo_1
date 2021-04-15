//
//  RegularNavBarViewController.swift
//  ForwardLeasing
//

import UIKit

class RegularNavBarViewController: BaseViewController, NavigationBarHiding, RoundedNavigationBarHaving {
  // MARK: - Subviews
  var scrollView: UIScrollView {
    return defaultScrollView
  }
  
  var defaultTopContentInset: CGFloat {
    return navigationBarView.maskArcHeight + scrollViewAdditionalTopOffset
  }
  
  let navigationBarView: NavigationBarView
  private let defaultScrollView = UIScrollView()
  
  // MARK: - Properties
  var scrollViewAdditionalTopOffset: CGFloat {
    return 24
  }
  
  var scrollViewLastOffset: CGFloat = 0
  
  private var updatedContentOffset = false
  
  // MARK: - Init
  init(navigationBarType: NavigationBarViewType = .titleAlwaysVisible()) {
    navigationBarView = NavigationBarView(type: navigationBarType)
    super.init(nibName: nil, bundle: nil)
  }
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    navigationBarView = NavigationBarView(type: .titleAlwaysVisible())
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Lifecycle
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    if !updatedContentOffset {
      updatedContentOffset = true
      scrollView.setContentOffset(.zero, animated: false)
      navigationBarView.setNeedsLayout()
      navigationBarView.layoutIfNeeded()
      navigationBarView.setState(isCollapsed: false, animated: false)
      navigationBarView.layer.zPosition = 1
    }
  }
  
  // MARK: - Public
  func setupNavigationBarView(title: String? = nil,
                              leftViews: [UIView] = [],
                              rightViews: [UIView] = [],
                              onDidTapBack: (() -> Void)? = nil) {
    view.addSubview(navigationBarView)
    navigationBarView.snp.makeConstraints { make in
      make.leading.top.trailing.equalToSuperview()
    }
    navigationBarView.configureNavigationBarTitle(title: title, leftViews: leftViews,
                                                  rightViews: rightViews)
    navigationBarView.addBackButton {
      onDidTapBack?()
    }
  }
  
  func setupScrollView() {
    view.addSubview(scrollView)
    scrollView.delegate = self
    scrollView.alwaysBounceVertical = false
    scrollView.showsVerticalScrollIndicator = false
    scrollView.contentInset.top = defaultTopContentInset
    scrollView.snp.makeConstraints { make in
      make.leading.trailing.bottom.equalToSuperview()
      make.top.equalTo(navigationBarView).offset(navigationBarView.titleViewMaxY)
    }
  }
  
  func handleScrollIfNeeded(_ scrollView: UIScrollView) {
    guard scrollView.contentSize.height > 0 else {
      return
    }
    handleScrollDefault(scrollView: scrollView)
  }
}

// MARK: - UIScrollViewDelegate
extension RegularNavBarViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    handleScrollIfNeeded(scrollView)
  }
}
