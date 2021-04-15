//
//  ErrorEmptyViewDisplaying.swift
//  ForwardLeasing
//

import UIKit

protocol ErrorEmptyViewDisplaying: class {
  var errorEmptyView: ErrorEmptyView { get }
  var errorViewParent: UIView { get }

  func addErrorEmptyView()
  func handleEmptyViewRefreshButtonTapped()
  func handleErrorEmptyViewHiddenStateChanged(isHidden: Bool)
}

extension ErrorEmptyViewDisplaying {
  func handleErrorEmptyViewHiddenStateChanged(isHidden: Bool) {}
}

enum ErrorEmptyViewShowingReason {
  case noInternet, backendError(String?)
}

extension ErrorEmptyViewDisplaying where Self: UIViewController {
  var errorViewParent: UIView {
    return view
  }

  var isDisplayingErrorView: Bool {
    return !errorEmptyView.isHidden && errorEmptyView.superview != nil
  }

  func addErrorEmptyView() {
    errorViewParent.addSubview(errorEmptyView)
    errorEmptyView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    errorEmptyView.isHidden = true
    errorEmptyView.onRefreshTap = { [unowned self] in
      self.handleEmptyViewRefreshButtonTapped()
    }
  }

  func showErrorEmptyView(reason: ErrorEmptyViewShowingReason) {
    let strings = R.string.errorEmptyView.self

    switch reason {
    case .noInternet:
      errorEmptyView.configure(title: strings.noInternetTitleText(), text: strings.noInternetSubtitleText())
    case .backendError:
      errorEmptyView.configure(title: strings.serverErrorTitleText(), text: strings.serverErrorSubtitleText())
    }

    errorEmptyView.isHidden = false
    handleErrorEmptyViewHiddenStateChanged(isHidden: false)
    setNeedsStatusBarAppearanceUpdate()
  }

  func handle(dataDefiningError error: Error) {
    var errorDescription: String?
    if error is LocalizedError
      || !((error as NSError).userInfo[NSLocalizedDescriptionKey] as? String).isEmptyOrNil,
      !error.localizedDescription.isEmpty {
      errorDescription = error.localizedDescription
    }
    var reason: ErrorEmptyViewShowingReason = .backendError(errorDescription)
    if NetworkErrorService.isOfflineError(error) {
      reason = .noInternet
    }
    showErrorEmptyView(reason: reason)
  }

  func handle(error: Error, refreshButtonTitle: String) {
    errorEmptyView.configure(title: error.localizedDescription, text: nil, refreshButtonTitle: refreshButtonTitle)
    errorEmptyView.isHidden = false
    setNeedsStatusBarAppearanceUpdate()
  }

  func hideErrorEmptyView(completion: (() -> Void)? = nil) {
    guard errorEmptyView.alpha == 1 else {
      completion?()
      return
    }
    errorEmptyView.isHidden = true
    handleErrorEmptyViewHiddenStateChanged(isHidden: true)
    setNeedsStatusBarAppearanceUpdate()
    completion?()
  }
}
