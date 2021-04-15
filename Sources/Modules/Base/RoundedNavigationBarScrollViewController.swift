//
//  RoundedNavigationBarScrollViewController.swift
//  ForwardLeasing
//

import UIKit

class RoundedNavigationBarScrollViewController: RegularNavBarViewController, ActivityIndicatorViewDisplaying,
                                                ErrorEmptyViewDisplaying, ViewModelBinding {
  // MARK: - Properties
  
  var shouldShowActivityIndicator: Bool {
    !navigationBarView.isRefreshing
  }
  
  let activityIndicatorView = ActivityIndicatorView()
  let errorEmptyView = ErrorEmptyView()
  
  private var currentNavBarContentContainerHeight: CGFloat = 0
  
  // MARK: - Overrides
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    view.bringSubviewToFront(navigationBarView)
    view.bringSubviewToFront(activityIndicatorView)
    view.bringSubviewToFront(errorEmptyView)
  }
  
  // MARK: - Public methods
  
  func handleStartRefreshing() {
    // Method to override
  }
  
  func handleEmptyViewRefreshButtonTapped() {
    // Method to override
  }
  
  func handleRequestStarted(shouldShowActivityIndicator: Bool) {
    if shouldShowActivityIndicator {
      scrollView.isHidden = true
    }
  }
  
  func handleRequestFinished() {
    navigationBarView.endRefreshing {
      self.updateForNavBarContentContainerHeight(height: self.currentNavBarContentContainerHeight)
    }
  }
  
  func reloadViews() {
    scrollView.isHidden = false
  }
  
  // MARK: - Setup
  
  private func setup() {
    addActivityIndicatorView()
    addErrorEmptyView()
    setupNavigationBarView()
    setupScrollView()
  }
  
  private func setupNavigationBarView() {
    view.addSubview(navigationBarView)
    navigationBarView.snp.makeConstraints { make in
      make.leading.top.trailing.equalToSuperview()
    }
    
    navigationBarView.onDidUpdateContentContainerHeight = { [weak self] height in
      self?.currentNavBarContentContainerHeight = height
      self?.updateForNavBarContentContainerHeight(height: height)
    }
    navigationBarView.onDidStartRefreshing = { [weak self] additionalHeight in
      guard let self = self else {
        return
      }
      self.updateForNavBarContentContainerHeight(height: self.currentNavBarContentContainerHeight + additionalHeight)
      self.handleStartRefreshing()
    }
    navigationBarView.onNeedsToLayoutSuperview = { [unowned self] in
      self.view.layoutIfNeeded()
    }
  }
  
  // MARK: - Private methods
  
  private func updateForNavBarContentContainerHeight(height: CGFloat) {
    let topInset = height + navigationBarView.maskArcHeight + scrollViewAdditionalTopOffset
    
    scrollView.contentInset.top = topInset
    
    activityIndicatorView.snp.remakeConstraints { make in
      make.centerX.equalToSuperview()
      make.centerY.equalToSuperview().multipliedBy(1 + 0.5 * (view.bounds.height - topInset) / view.bounds.height)
    }
    activityIndicatorView.layoutIfNeeded()
    
    errorEmptyView.snp.remakeConstraints { make in
      make.leading.trailing.bottom.equalToSuperview()
      make.top.equalToSuperview().offset(topInset - scrollViewAdditionalTopOffset)
    }
    errorEmptyView.layoutIfNeeded()
    
    if scrollView.contentOffset.y <= 0 {
      scrollView.setContentOffset(CGPoint(x: 0, y: -topInset), animated: false)
    }
  }
}
