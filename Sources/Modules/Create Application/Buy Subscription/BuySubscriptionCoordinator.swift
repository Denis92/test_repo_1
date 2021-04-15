//
//  BuySubscriptionCoordinator.swift
//  ForwardLeasing
//

import UIKit

protocol BuySubscriptionCoordinatorDelegate: class {
  func buySubscriptionCoordinatorDidRequestPopToCatalogue(_ coordinator: BuySubscriptionCoordinator)
  func buySubscriptionCoordinatorDidRequestPopToProfile(_ coordinator: BuySubscriptionCoordinator)
}

extension BuySubscriptionCoordinatorDelegate {
  func buySubscriptionCoordinatorDidRequestPopToCatalogue(_ coordinator: BuySubscriptionCoordinator) {}
  func buySubscriptionCoordinatorDidRequestPopToProfile(_ coordinator: BuySubscriptionCoordinator) {}
}

enum BuySubscriptionFlow {
  case catalogue
  case profile
}

struct BuySubscriptionConfiguration {
  let name: String
  let subscriptionItemID: String
  let selectedCard: PaymentCard
  let saveCard: Bool
  let flow: BuySubscriptionFlow
}

class BuySubscriptionCoordinator: ConfigurableNavigationFlowCoordinator {
  typealias Configuration = BuySubscriptionConfiguration
  // MARK: - Properties
  weak var delegate: BuySubscriptionCoordinatorDelegate?
  
  let appDependency: AppDependency
  let navigationObserver: NavigationObserver
  let navigationController: NavigationController
  var childCoordinators: [BaseCoordinator] = []
  var onDidFinish: (() -> Void)?
  
  private let configuration: Configuration
  private let paymentUtility = PaymentUtility()
  
  // MARK: - Init
  required init(appDependency: AppDependency,
                navigationController: NavigationController,
                navigationObserver: NavigationObserver,
                configuration: Configuration) {
    self.navigationController = navigationController
    self.navigationObserver = navigationObserver
    self.appDependency = appDependency
    self.configuration = configuration
    paymentUtility.delegate = self
  }
  
  // MARK: - Public Methods
  
  func start(animated: Bool) {
    showBuySubscription()
  }
  
  // MARK: - Private Methods
  private func showBuySubscription() {
    let input = BuySubscriptionRegisterViewModelInput(name: configuration.name,
                                                      subscriptionItemID: configuration.subscriptionItemID,
                                                      card: configuration.selectedCard,
                                                      saveCard: configuration.saveCard)
    let viewModel = BuySubscriptionRegisterViewModel(dependencies: appDependency, input: input)
    viewModel.delegate = self
    let controller = BuySubscriptionRegisterViewController(viewModel: viewModel)
    controller.delegate = self
    navigationController.pushViewController(controller, animated: true)
  }
  
  private func showWebView(with url: URL, isPayment: Bool = false) {
    let controller = WebViewController(url: url)
    controller.delegate = isPayment ? paymentUtility : nil
    navigationController.pushViewController(controller, animated: true)
  }
  
  private func showPaymentSuccess(_ isSuccess: Bool) {
    let successType: SuccessViewControllerType = isSuccess ?
      .success(title: R.string.subscriptionRegister.successPaymentResultTitle()):
      .fail(title: R.string.common.error(),
            subtitle: R.string.subscriptionRegister.failedPaymentResultTitle())
    let controller = SuccessViewController(type: successType) { [weak self] in
      guard let self = self else { return }
      switch self.configuration.flow {
      case .catalogue:
        self.delegate?.buySubscriptionCoordinatorDidRequestPopToCatalogue(self)
      case .profile:
        self.delegate?.buySubscriptionCoordinatorDidRequestPopToProfile(self)
      }
      self.onDidFinish?()
    }
    navigationController.pushViewController(controller, animated: true)
  }
}

// MARK: - BuySubscriptionRegisterViewModelDelegate
extension BuySubscriptionCoordinator: BuySubscriptionRegisterViewModelDelegate {
  func buySubscriptionRegisterViewModel(_ viewModel: BuySubscriptionRegisterViewModel, didRequestShowPaymentWithURL url: URL) {
    showWebView(with: url, isPayment: true)
  }
  
  func registerViewModel(_ viewModel: RegisterViewModel, didRequestOpeURL url: URL) {
    showWebView(with: url)
  }
}

// MARK: - PaymentUtilityDelegate
extension BuySubscriptionCoordinator: PaymentUtilityDelegate {
  func paymentUtilityDidFail(_ utility: PaymentUtility) {
    showPaymentSuccess(false)
  }
  
  func paymentUtilityDidFinishSuccess(_ utility: PaymentUtility) {
    showPaymentSuccess(true)
  }
}

// MARK: - RegisterViewControllerDelegate
extension BuySubscriptionCoordinator: RegisterViewControllerDelegate {
  func registerViewControllerDidRequestGoBack(_ viewController: RegisterViewController) {
    navigationController.popViewController(animated: true)
  }
}
