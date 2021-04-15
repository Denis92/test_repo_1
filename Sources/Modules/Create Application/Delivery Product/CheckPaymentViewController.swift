//
//  CheckPaymentViewController.swift
//  ForwardLeasing
//

import UIKit

class CheckPaymentViewController: BaseViewController, NavigationBarHiding {
  // MARK: - Subviews
  private let timerView = TimerView()
  private let deliveryPaymentFailedView = PaymentFailedView()
  
  // MARK: - Properties
  
  private let viewModel: CheckPaymentViewModel
  
  // MARK: - Init
  
  init(viewModel: CheckPaymentViewModel) {
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
    bind()
    viewModel.checkPayment()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    viewModel.startTimer()
  }

  // MARK: - Private Methods
  
  private func setup() {
    setupTimerView()
    setupDeliveryPaymentFailedView()
  }
  
  private func bind() {
    viewModel.onDidStartTimer = { [weak self] in
      self?.setupTimerState()
    }
    viewModel.onDidReceivePaymentError = { [weak self] in
      self?.setupFailedState()
    }
    viewModel.onDidCancelAlert = { [weak self] in
      self?.showCancelAlert()
    }
  }
  
  private func setupTimerView() {
    view.addSubview(timerView)
    timerView.configure(with: viewModel.timerViewModel)
    timerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  private func setupDeliveryPaymentFailedView() {
    view.addSubview(deliveryPaymentFailedView)
    deliveryPaymentFailedView.configure(with: viewModel.deliveryPaymentFailedViewModel)
    deliveryPaymentFailedView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    deliveryPaymentFailedView.isHidden = true
  }
  
  // MARK: - States
  private func setupTimerState() {
    timerView.isHidden = false
    deliveryPaymentFailedView.isHidden = true
  }
  
  private func setupFailedState() {
    timerView.isHidden = true
    deliveryPaymentFailedView.isHidden = false
  }
  
  private func showCancelAlert() {
    showAppAlert(message: R.string.deliveryProduct.cancelAlertMessage(),
                 actions: viewModel.cancelDeliveryAlertActions)
  }
}
