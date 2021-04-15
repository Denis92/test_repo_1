//
//  PaymentCoordinator.swift
//  ForwardLeasing
//

import Foundation

protocol PaymentCoordinatorDelegate: class {
  func paymentCoordinatorDidFinish(_ coordinator: PaymentCoordinator)
  func paymentCoordinatorDidRequestRepeatPayment(_ coordinator: PaymentCoordinator)
  func paymentCoordinatorDidRequestCheckLater(_ coordinator: PaymentCoordinator)
}

struct PaymentCoordinatorConfiguration {
  let paymentURL: URL
}

class PaymentCoordinator: ConfigurableNavigationFlowCoordinator {
  typealias Configuration = PaymentCoordinatorConfiguration

  // MARK: - Properties

  let appDependency: AppDependency
  let navigationObserver: NavigationObserver
  let navigationController: NavigationController
  var childCoordinators: [BaseCoordinator] = []
  var onDidFinish: (() -> Void)?

  weak var delegate: PaymentCoordinatorDelegate?

  private var onDidRequestShowQuestionnary: (() -> Void)?
  private var onDidRequestPopToStart: (() -> Void)?
  private var onDidRequestUpdateExchangeInfo: (() -> Void)?

  private let configuration: Configuration
  private let paymentUtility: PaymentUtility

  required init(appDependency: AppDependency,
                navigationController: NavigationController,
                navigationObserver: NavigationObserver,
                configuration: Configuration) {
    self.appDependency = appDependency
    self.navigationController = navigationController
    self.navigationObserver = navigationObserver
    self.configuration = configuration
    self.paymentUtility = PaymentUtility()
    self.paymentUtility.delegate = self
  }

  // MARK: - Navigation
  func start(animated: Bool) {
    showPayment(with: configuration.paymentURL)
  }

  private func showPayment(with url: URL) {
    let viewController = WebViewController(url: url)
    viewController.delegate = paymentUtility
    navigationObserver.addObserver(self, forPopOf: viewController)
    navigationController.pushViewController(viewController, animated: true)
  }

  private func showFail() {
    let viewModel = PaymentFailedViewModel()
    viewModel.delegate = self
    let viewController = PaymentFailedViewController(viewModel: viewModel)
    navigationController.pushViewController(viewController, animated: true)
  }

  private func showSuccess() {
    let successType = SuccessViewControllerType.success(title: R.string.deliveryProduct.paymentSuccessTitle())
    let viewController = SuccessViewController(type: successType) { [weak self] in
      guard let self = self else { return }
      self.delegate?.paymentCoordinatorDidFinish(self)
      self.onDidFinish?()
    }
    navigationController.pushViewController(viewController, animated: true)
  }

}

// MARK: - PaymentUtilityDelegate

extension PaymentCoordinator: PaymentUtilityDelegate {
  func paymentUtilityDidFail(_ utility: PaymentUtility) {
    showFail()
  }

  func paymentUtilityDidFinishSuccess(_ utility: PaymentUtility) {
    showSuccess()
  }
}

// MARK: - PaymentFailedViewModelDelegate

extension PaymentCoordinator: PaymentFailedViewModelDelegate {
  func paymentFailedViewModelDidRequestRepeatPayment(_ viewModel: PaymentFailedViewModel) {
    delegate?.paymentCoordinatorDidRequestRepeatPayment(self)
    onDidFinish?()
  }

  func paymentFailedViewModelDidRequestCheckLater(_ viewModel: PaymentFailedViewModel) {
    delegate?.paymentCoordinatorDidRequestCheckLater(self)
    onDidFinish?()
  }

}
