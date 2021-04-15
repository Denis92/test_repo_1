//
//  ActivityIndicatorController.swift
//  ForwardLeasing
//

import UIKit

class ActivityIndicatorController: BaseViewController {
  private let activityIndicator = ActivityIndicatorView()
  // swiftlint:disable:next weak_delegate
  private let activityIndicatorTransiotioningDelegate = ActivityIndicatorTransitioningDelegate()
  
  init() {
    super.init(nibName: nil, bundle: nil)
    modalPresentationStyle = .custom
    transitioningDelegate = activityIndicatorTransiotioningDelegate
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    activityIndicator.isAnimating = false
  }
  
  private func setup() {
    view.addSubview(activityIndicator)
    activityIndicator.isAnimating = true
    activityIndicator.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }
}
