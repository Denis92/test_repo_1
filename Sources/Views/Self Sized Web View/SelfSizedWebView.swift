//
//  InfoWebView.swift
//  ForwardLeasing
//

import UIKit
import WebKit

private extension Constants {
  static var scrollHeightJavaScript: String {
    return isIOS13Available
      ? "document.documentElement.scrollHeight"
      : "document.body.scrollHeight"
  }
  static let readyStateJavaScript: String = "document.readyState"
}

protocol SelfSizedWebViewModelProtocol: class {
  var infoURLRequest: URLRequest? { get }
}

class SelfSizedWebView: UIView, Configurable {
  // MARK: - Properties
  private let webView = WKWebView()

  // MARK: - Init
  override init(frame: CGRect) {
    super.init(frame: frame)

    setup()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Configure
  func configure(with viewModel: SelfSizedWebViewModelProtocol) {
    guard let request = viewModel.infoURLRequest else {
      return
    }
    webView.load(request)
  }

  // MARK: - Private methods
  private func setup() {
    setupWebView()
  }

  private func setupWebView() {
    addSubview(webView)
    webView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    webView.scrollView.isScrollEnabled = false
    webView.navigationDelegate = self
  }

  private func handle(_ height: Any?) {
    guard let height = height as? CGFloat else {
      return
    }
    webView.snp.remakeConstraints { make in
      make.edges.equalToSuperview()
      make.height.equalTo(height)
    }
  }
}

// MARK: - WKNavigationDelegate
extension SelfSizedWebView: WKNavigationDelegate {
  // swiftlint:disable:next mplicitly_unwrapped_optional
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    webView.evaluateJavaScript(Constants.readyStateJavaScript) { [weak self] result, _ in
      let heightBlock: (Any?, Error?) -> Void = { [weak self] height, _ in
        self?.handle(height)
      }
      if result != nil {
        self?.webView.evaluateJavaScript(Constants.scrollHeightJavaScript,
                                         completionHandler: heightBlock)
      }
    }
  }
}
