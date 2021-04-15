//
//  WebViewController.swift
//  ForwardLeasing
//

import UIKit
import WebKit

private extension Constants {
  static let bearer = NetworkService.HeaderKeys.bearer
  static let authorization = NetworkService.HeaderKeys.authorization
}

protocol WebViewControllerDelegate: class {
  func webViewController(_ viewController: WebViewController,
                         shouldOpenURL url: URL) -> Bool
  func webViewController(_ viewController: WebViewController,
                         didFailWithError error: Error)
}

class WebViewController: UIViewController {
  // MARK: - Subviews
  private let webView = WKWebView()
  private let activityIndicatorView = ActivityIndicatorView()
  
  // MARK: - Properties
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  weak var delegate: WebViewControllerDelegate?
  
  // MARK: - Init
  
  init(url: URL, token: String? = nil) {
    super.init(nibName: nil, bundle: nil)
    var request = URLRequest(url: url)
    if let token = token {
      request.addValue([Constants.bearer, token].joined(separator: " "), forHTTPHeaderField: Constants.authorization)
    }
    log.debug(request)
    webView.load(request)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Overrides
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  // MARK: - Setup
  
  private func setup() {
    setupWebView()
    setupActivityIndicator()
  }
  
  private func setupWebView() {
    view.addSubview(webView)
    webView.navigationDelegate = self
    webView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  private func setupActivityIndicator() {
    view.addSubview(activityIndicatorView)
    activityIndicatorView.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }
}

// MARK: - WKNavigationDelegate

extension WebViewController: WKNavigationDelegate {
  // swiftlint:disable:next implicitly_unwrapped_optional
  func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    activityIndicatorView.startAnimating()
  }
  
  // swiftlint:disable:next implicitly_unwrapped_optional
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    activityIndicatorView.stopAnimating()
  }
  
  func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
               decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    guard let url = navigationAction.request.url else {
      decisionHandler(.cancel)
      return
    }
    log.debug("Did request open: \(url)")
    guard let shouldOpen = delegate?.webViewController(self, shouldOpenURL: url) else {
      decisionHandler(.allow)
      return
    }
    decisionHandler(shouldOpen ? .allow : .cancel)
  }
  
  func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
    log.error("Web view did fail with error: \(error.localizedDescription)")
    delegate?.webViewController(self, didFailWithError: error)
  }
}
