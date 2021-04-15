//
//  PaymentRegistrationCoordinator.swift
//  ForwardLeasing
//

import UIKit

protocol PaymentRegistrationCoordinatorDelegate: class {
  func paymentRegistrationCoordinatorDidFinishSuccess(_ coordinator: PaymentRegistrationCoordinator)
}

struct PaymentRegistrationCoordinatorConfig {
  let contract: LeasingEntity
}

class PaymentRegistrationCoordinator: ConfigurableNavigationFlowCoordinator {
  typealias Configuration = PaymentRegistrationCoordinatorConfig
  
  // MARK: - Properties
  weak var delegate: PaymentRegistrationCoordinatorDelegate?
  
  let appDependency: AppDependency
  let navigationObserver: NavigationObserver
  let navigationController: NavigationController
  var childCoordinators: [BaseCoordinator] = []
  var onDidFinish: (() -> Void)?
  var presentingController: UIViewController {
    return navigationController.topViewController ?? navigationController
  }
  
  private var onDidRequestShowPaymentResult: (() -> Void)?
  
  private let configuration: Configuration
  
  // swiftlint:disable:next weak_delegate
  private lazy var transitioningDelegate = PopupTransitioningDelegate()
  
  private let paymentUtility = PaymentUtility()

  required init(appDependency: AppDependency,
                navigationController: NavigationController,
                navigationObserver: NavigationObserver,
                configuration: Configuration) {
    self.appDependency = appDependency
    self.navigationController = navigationController
    self.navigationObserver = navigationObserver
    self.configuration = configuration
    paymentUtility.delegate = self
  }

  // MARK: - Navigation
  func start(animated: Bool) {
    showPaymentRegistration()
  }
  
  private func showPaymentRegistration() {
    let viewModel = PaymentRegistrationViewModel(contract: configuration.contract,
                                                 dependencies: appDependency)
    viewModel.delegate = self
    let viewController = PaymentRegistrationViewController(viewModel: viewModel)
    viewController.modalPresentationStyle = .custom
    viewController.transitioningDelegate = transitioningDelegate
    presentingController.present(viewController, animated: true, completion: nil)
  }
  
  private func showPayment(with url: URL) {
    let viewController = WebViewController(url: url)
    viewController.delegate = paymentUtility
    navigationObserver.addObserver(self, forPopOf: viewController)
    navigationController.pushViewController(viewController, animated: true)
  }
  
  private func showPaymentResult(isSuccess: Bool) {
    let viewController = PaymentResultViewController(isSuccess: isSuccess)
    viewController.modalPresentationStyle = .custom
    viewController.transitioningDelegate = transitioningDelegate
    viewController.delegate = self
    presentingController.present(viewController, animated: true, completion: nil)
  }
}

// MARK: - PaymentRegistrationViewModelDelegate
extension PaymentRegistrationCoordinator: PaymentRegistrationViewModelDelegate {
  func paymentRegistrationViewModelDidCancel(_ viewModel: PaymentRegistrationViewModel) {
    presentingController.dismiss(animated: true, completion: nil)
  }

  func paymentRegistrationViewModel(_ viewModel: PaymentRegistrationViewModel,
                                    didFinishWithPaymentURL paymentURL: URL) {
    presentingController.dismiss(animated: true) { [weak self] in
      self?.showPayment(with: paymentURL)
    }
  }
}

// MARK: - PaymentResultViewControllerDelegate
extension PaymentRegistrationCoordinator: PaymentResultViewControllerDelegate {
  func paymentResultViewControllerDidRequestClose(_ viewController: PaymentResultViewController) {
    presentingController.dismiss(animated: true) { [weak self] in
      guard let self = self else { return }
      self.delegate?.paymentRegistrationCoordinatorDidFinishSuccess(self)
    }
  }
}

// MARK: - PaymentUtilityDelegate
extension PaymentRegistrationCoordinator: PaymentUtilityDelegate {
  func paymentUtilityDidFail(_ utility: PaymentUtility) {
    onDidRequestShowPaymentResult = {
      self.showPaymentResult(isSuccess: false)
    }
    navigationController.popViewController(animated: true)
  }
  
  func paymentUtilityDidFinishSuccess(_ utility: PaymentUtility) {
    onDidRequestShowPaymentResult = {
      self.showPaymentResult(isSuccess: true)
    }
    navigationController.popViewController(animated: true)
  }
}

// MARK: - Navigation Observer
extension PaymentRegistrationCoordinator: NavigationPopObserver {
  func navigationObserver(_ observer: NavigationObserver,
                          didObserveViewControllerPop viewController: UIViewController) {
    if viewController is WebViewController {
      onDidRequestShowPaymentResult?()
    }
  }
}
