//
//  PaymentFailedViewController.swift
//  ForwardLeasing
//

import UIKit

class PaymentFailedViewController: BaseViewController, NavigationBarHiding {
  // MARK: - Subviews
  private let paymentFailedView = PaymentFailedView()
  
  // MARK: - Properties
  
  private let viewModel: PaymentFailedViewModel
  
  // MARK: - Init
  
  init(viewModel: PaymentFailedViewModel) {
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
  }
  
  // MARK: - Private Methods
  
  private func setup() {
    setupPaymentFailedView()
  }

  private func setupPaymentFailedView() {
    view.addSubview(paymentFailedView)
    paymentFailedView.configure(with: viewModel.paymentFailedViewModel)
    paymentFailedView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
}
