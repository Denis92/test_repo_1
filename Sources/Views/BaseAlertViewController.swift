//
//  PopupAlertViewController.swift
//  ForwardLeasing
//

import UIKit
import SnapKit

class BaseAlertViewController: UIViewController {
  // MARK: - Subviews
  
  private var alertContainerView = UIView()
  private var containerView = UIView()
  
  private let closesOnBackgroundTap: Bool
  
  // MARK: - Init
  
  init(closesOnBackgroundTap: Bool = true) {
    self.closesOnBackgroundTap = closesOnBackgroundTap
    super.init(nibName: nil, bundle: nil)
    modalPresentationStyle = .overCurrentContext
    modalTransitionStyle = .crossDissolve
    setup()
  }
  
  required init?(coder aCoder: NSCoder) {
    self.closesOnBackgroundTap = true
    super.init(coder: aCoder)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    animateIn()
  }
  
  // MARK: - Setup
  
  private func setup() {
    setupContainerView()
    setupAlertContainerView()
    if closesOnBackgroundTap {
      setupGestureRecognizer()
    }
  }
  
  private func setupContainerView() {
    view.addSubview(containerView)
    containerView.backgroundColor = UIColor.base1.withAlphaComponent(0.6)
    containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  private func setupAlertContainerView() {
    view.addSubview(alertContainerView)
    alertContainerView.alpha = 0
    alertContainerView.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }
  
  private func setupGestureRecognizer() {
    let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
    containerView.isUserInteractionEnabled = true
    containerView.addGestureRecognizer(gestureRecognizer)
  }
  
  private func animateIn() {
    UIView.animate(withDuration: 0.2) {
      self.alertContainerView.alpha = 1
    }
  }
  
  private func animateOut() {
    UIView.animate(withDuration: 0.2) {
      self.alertContainerView.alpha = 0
    }
  }
  
  func addPopupAlert(_ popupAlert: UIView) {
    alertContainerView.addSubview(popupAlert)
    alertContainerView.snp.remakeConstraints { make in
      make.centerY.equalToSuperview()
      make.leading.trailing.equalToSuperview().inset(15)
    }
    popupAlert.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  @objc func handleTap(_ sender: UITapGestureRecognizer) {
    self.dismiss(animated: true) {
      self.animateOut()
    }
  }
}
