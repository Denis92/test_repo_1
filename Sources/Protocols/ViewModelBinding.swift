//
//  ViewModelBinding.swift
//  ForwardLeasing
//

import UIKit

protocol BindableViewModel: class {
  var onDidStartRequest: (() -> Void)? { get set }
  var onDidFinishRequest: (() -> Void)? { get set }
  var onDidRequestToShowErrorBanner: ((Error) -> Void)? { get set }
  var onDidRequestToShowEmptyErrorView: ((Error) -> Void)? { get set }
  var onDidLoadData: (() -> Void)? { get set }
}

protocol ViewModelBinding: class {
  func bind(to viewModel: BindableViewModel)
  func reloadViews()

  func handleRequestStarted(shouldShowActivityIndicator: Bool)
  func handleRequestFinished()
}

extension ViewModelBinding {
  func handleRequestStarted(shouldShowActivityIndicator: Bool) {}
  func handleRequestFinished() {}
  func reloadViews() {}
}

extension ViewModelBinding where Self: UIViewController & ErrorEmptyViewDisplaying {
  func bind(to viewModel: BindableViewModel) {
    viewModel.onDidStartRequest = { [weak self] in
      if self?.isDisplayingErrorView == true {
        self?.errorEmptyView.startAnimating()
      }
      var shouldShowActivityIndicator = false
      if let activityIndicatorShowing = self as? ActivityIndicatorViewDisplaying & ViewModelBinding,
        activityIndicatorShowing.shouldShowActivityIndicator, self?.isDisplayingErrorView != true {
        shouldShowActivityIndicator = true
        activityIndicatorShowing.activityIndicatorView.startAnimating()
      }
      self?.handleRequestStarted(shouldShowActivityIndicator: shouldShowActivityIndicator)
    }

    viewModel.onDidFinishRequest = { [weak self] in
      self?.errorEmptyView.stopAnimating()
      if let activityIndicatorShowing = self as? ActivityIndicatorViewDisplaying & ViewModelBinding {
        activityIndicatorShowing.activityIndicatorView.stopAnimating()
      }
      self?.handleRequestFinished()
      if let reloading = self as? DataReloading, reloading.refreshControl.isRefreshing {
        reloading.refreshControl.endRefreshing()
      }
    }

    viewModel.onDidRequestToShowErrorBanner = { [weak self] error in
      self?.handle(error: error)
    }

    viewModel.onDidRequestToShowEmptyErrorView = { [weak self] error in
      self?.handle(dataDefiningError: error)
    }

    viewModel.onDidLoadData = { [weak self] in
      self?.hideErrorEmptyView {
        self?.reloadViews()
      }
    }
  }
}
