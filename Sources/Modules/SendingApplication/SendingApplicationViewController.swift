//
//  SendingApplicationViewController.swift
//  ForwardLeasing
//

import UIKit

class SendingApplicationViewController: UIViewController, NavigationBarHiding,
                                        ActivityIndicatorPresenting {
  // MARK: - Subviews
  private let sendingApplicationView = SendingApplicationView()
  private let timerView = TimerView()
  private let longerThanNecesseryView = LongerThanNecessaryView()
  private let acceptedView = AcceptedView()
  private let deniedView = DeniedView()
  
  private let viewModel: SendingApplicationViewModel
  
  // MARK: - Init
  init(viewModel: SendingApplicationViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    bindToViewModel()
    viewModel.sendApplicationForScoring()
  }
  
  private func bindToViewModel() {
    viewModel.onDidChangeState = { [weak self] state in
      self?.showView(state)
    }
    viewModel.onDidContinueLongerThanNeccessary = { [weak self] in
      self?.showView(.longerThanNecessary)
    }
    viewModel.onDidReceiveError = { [weak self] error in
      self?.handle(error: error)
    }
    viewModel.onDidStartRequest = { [weak self] in
      self?.acceptedView.startAnimatingButton()
    }
    viewModel.onDidFinishRequest = { [weak self] in
      self?.acceptedView.stopAnimatingButton()
    }
    viewModel.onDidRequestToCancelLeasingEntity = { [weak self] callback in
      self?.showCancelLeasingEntityAlert(callback: callback)
    }
    viewModel.onDidRequestToPresentActivityIndicator = { [weak self] in
      self?.presentActivtiyIndicator(completion: nil)
    }
    viewModel.onDidRequestToHideActivityIndicator = { [weak self] in
      self?.dismissActivityIndicator(completion: nil)
    }
  }

  private func showView(_ state: SendingApplicationState) {
    switch state {
    case .timer:
      makeViewVisible(timerView)
    case .longerThanNecessary:
      longerThanNecesseryView.configure(with: viewModel.longerThanNecessaryViewModel)
      makeViewVisible(longerThanNecesseryView)
    case .approved:
      makeViewVisible(acceptedView)
    case .notSent, .isImpossible, .denied:
      deniedView.configure(with: viewModel.deniedViewModel)
      makeViewVisible(deniedView)
    case .sending:
      makeViewVisible(sendingApplicationView)
    }
  }
  
  private func makeViewVisible(_ currentView: UIView) {
    view.subviews.forEach { $0.isHidden = true }
    currentView.isHidden = false
  }
  
  private func setup() {
    view.backgroundColor = .base2
    setupSendingApplicationView()
    setupTimerView()
    setupLongerThanNecessaryView()
    setupAcceptedView()
    setupDeniedView()
  }
  
  private func setupSendingApplicationView() {
    view.addSubview(sendingApplicationView)
    sendingApplicationView.isHidden = true
    sendingApplicationView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  private func setupTimerView() {
    view.addSubview(timerView)
    timerView.isHidden = true
    timerView.configure(with: viewModel.timerViewModel)
    timerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  private func setupLongerThanNecessaryView() {
    view.addSubview(longerThanNecesseryView)
    longerThanNecesseryView.configure(with: viewModel.longerThanNecessaryViewModel)
    longerThanNecesseryView.isHidden = true
    longerThanNecesseryView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  private func setupAcceptedView() {
    view.addSubview(acceptedView)
    acceptedView.isHidden = true
    acceptedView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    acceptedView.onDidTapFinishButton = { [weak self] in
      self?.viewModel.finish()
    }
  }
  
  private func setupDeniedView() {
    view.addSubview(deniedView)
    deniedView.isHidden = true
    deniedView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  // MARK: - Private methods
  
  private func showCancelLeasingEntityAlert(callback: @escaping () -> Void) {
    let alertController = BaseAlertViewController()
    let popup = PopupAlertView(R.string.profile.cancelApplicationAlertTitle())
    alertController.addPopupAlert(popup)
    
    let confirmButton = StandardButton(type: .primary)
    confirmButton.setTitle(R.string.common.yes(), for: .normal)
    confirmButton.actionHandler(controlEvents: .touchUpInside) { [weak alertController] in
      alertController?.dismiss(animated: true) {
        callback()
      }
    }
    popup.addButton(confirmButton)
    
    let cancelButton = StandardButton(type: .secondary)
    cancelButton.setTitle(R.string.common.cancel(), for: .normal)
    cancelButton.actionHandler(controlEvents: .touchUpInside) { [weak alertController] in
      alertController?.dismiss(animated: true, completion: nil)
    }
    popup.addButton(cancelButton)
    
    present(alertController, animated: true, completion: nil)
  }
}
