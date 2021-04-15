//
//  ActivityIndicatorView.swift
//  ForwardLeasing
//

import UIKit

class ActivityIndicatorView: UIView {
  // MARK: - Properties
  var isAnimating: Bool {
    get {
      return activityIndicator.isAnimating
    }
    set {
      activityIndicator.isHidden = !newValue
      newValue ? startAnimating() : stopAnimating()
    }
  }
  
  private let activityIndicatorColor: UIColor
  private let stackView = UIStackView()
  private let loadingLabel = AttributedLabel(textStyle: .title2Bold)
  private let activityIndicator: UIActivityIndicatorView
  private let spacing: CGFloat
  private let title: String?

  // MARK: - Init
  init(style: UIActivityIndicatorView.Style = .whiteLarge,
       color: UIColor = .base1, title: String? = nil,
       spacing: CGFloat = 32) {
    self.activityIndicatorColor = color
    self.activityIndicator = UIActivityIndicatorView(style: style)
    self.spacing = spacing
    self.title = title
    super.init(frame: .zero)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    self.activityIndicatorColor = .base1
    self.activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
    self.spacing = 32
    self.title = nil
    super.init(coder: aDecoder)
  }
  
  // MARK: - Public
  func startAnimating() {
    activityIndicator.startAnimating()
    isHidden = activityIndicator.isHidden
  }

  func stopAnimating() {
    activityIndicator.stopAnimating()
    isHidden = activityIndicator.isHidden
  }

  // MARK: - Private
  private func setup() {
    setupStackView()
    setupActivityIndicator()
    setupLoadingLabel()
  }
  
  private func setupStackView() {
    addSubview(stackView)
    stackView.axis = .vertical
    stackView.spacing = spacing
    stackView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  private func setupActivityIndicator() {
    let activityIndicatorContainer = UIView()
    activityIndicatorContainer.addSubview(activityIndicator)
    activityIndicator.snp.makeConstraints { make in
      make.top.bottom.equalToSuperview()
      make.centerX.equalToSuperview()
    }
    stackView.addArrangedSubview(activityIndicatorContainer)
    isUserInteractionEnabled = false
    activityIndicator.hidesWhenStopped = true
    activityIndicator.color = activityIndicatorColor
  }
  
  private func setupLoadingLabel() {
    stackView.addArrangedSubview(loadingLabel)
    loadingLabel.textColor = .base1
    loadingLabel.text = title
    loadingLabel.textAlignment = .center
  }
}
