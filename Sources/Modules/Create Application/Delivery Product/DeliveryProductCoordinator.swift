//
//  DeliveryProductCoordinator.swift
//  ForwardLeasing
//

import UIKit

protocol DeliveryProductCoordinatorDelegate: AnyObject {
  func deliveryProductCoordinator(_ coordinator: DeliveryProductCoordinator,
                                  didFinishWithDeliveryWithLeasingEntity leasingEntity: LeasingEntity)
  func deliveryProductCoordinator(_ coordinator: DeliveryProductCoordinator,
                                  didFinishWithStorePointInfo storePoint: StorePointInfo,
                                  application: LeasingEntity)
  func deliveryProductCoordinatorDidCancelDelivery(_ coordinator: DeliveryProductCoordinator)
  func deliveryProductCoordinatorDidRequestReturnToProfile(_ coordinator: DeliveryProductCoordinator)
  func deliveryProductCoordinatorDidRequestToFinishFlow(_ coordinator: DeliveryProductCoordinator)
}

struct DeliveryProductCoordinatorConfiguration {
  var leasingEntity: LeasingEntity
}

class DeliveryProductCoordinator: ConfigurableNavigationFlowCoordinator {
  typealias Configuration = DeliveryProductCoordinatorConfiguration
  // MARK: - Properties
  
  weak var delegate: DeliveryProductCoordinatorDelegate?
  
  let appDependency: AppDependency
  let navigationObserver: NavigationObserver
  let navigationController: NavigationController
  var childCoordinators: [BaseCoordinator] = []
  var onDidFinish: (() -> Void)?
  
  private var configuration: DeliveryProductCoordinatorConfiguration
  private let utility: DeliveryProductCoordinatorUtility
  private var onNeedsShowCheckPayment: ((LeasingEntity) -> Void)?
  private var onDidFailPayment: (() -> Void)?
  
  // MARK: - Init
  
  required init(appDependency: AppDependency,
                navigationController: NavigationController,
                navigationObserver: NavigationObserver,
                configuration: Configuration) {
    self.navigationController = navigationController
    self.navigationObserver = navigationObserver
    self.appDependency = appDependency
    self.configuration = configuration
    let paymentUtility = PaymentUtility()
    utility = DeliveryProductCoordinatorUtility(userDataStore: appDependency.userDataStore,
                                                deliveryProductPaymentUtility: paymentUtility)
    paymentUtility.delegate = self
  }
  
  // MARK: - Public Methods
  
  func start(animated: Bool) {
    if configuration.leasingEntity.contractActionInfo?.deliveryInfo?.status == .createPayment {
      showCheckPayment(with: configuration.leasingEntity, isPaymentFailed: false)
    } else {
      showSelectDelivery()
    }
  }
  
  // MARK: - Private Methods
  private func showSelectDelivery() {
    let viewModel = SelectDeliveryViewModel(dependencies: appDependency, application: configuration.leasingEntity)
    viewModel.delegate = self
    let viewController = SelectDeliveryViewController(viewModel: viewModel)
    viewController.delegate = self
    navigationController.pushViewController(viewController, animated: true)
  }
  
  private func showStorePoints(with leasingEntity: LeasingEntity,
                               storePoint: StorePointInfo?) {
    let configuration = StorePointsCoordinatorConfiguration(leasingEntity: leasingEntity,
                                                            storePoint: storePoint)
    let coordinator = show(StorePointsCoordinator.self, configuration: configuration, animated: true)
    coordinator.delegate = self
  }
  
  private func showDeliveryPayment(with url: URL, leasingEntity: LeasingEntity) {
    let viewController = WebViewController(url: url)
    viewController.delegate = utility.deliveryProductPaymentUtility
    navigationController.pushViewController(viewController, animated: true)
  }
  
  private func showCheckPayment(with application: LeasingEntity,
                                isPaymentFailed: Bool) {
    let viewModel = CheckPaymentViewModel(dependencies: appDependency, application: application,
                                          isPaymentFailed: isPaymentFailed)
    viewModel.delegate = self
    let viewController = CheckPaymentViewController(viewModel: viewModel)
    navigationController.pushViewController(viewController, animated: true)
  }
  
  private func showSuccess() {
    let successType = SuccessViewControllerType.success(title: R.string.deliveryProduct.paymentSuccessTitle())
    let viewController = SuccessViewController(type: successType) { [weak self] in
      guard let self = self else { return }
      self.delegate?.deliveryProductCoordinator(self, didFinishWithDeliveryWithLeasingEntity: self.configuration.leasingEntity)
    }
    navigationController.pushViewController(viewController, animated: true)
  }
}

// MARK: - StorePointsCoordinatorDelegate
extension DeliveryProductCoordinator: StorePointsCoordinatorDelegate {
  func storePointsCoordinator(_ coordinator: StorePointsCoordinator,
                              didFinishWithSelectedStorePoint storePoint: StorePointInfo) {
    delegate?.deliveryProductCoordinator(self, didFinishWithStorePointInfo: storePoint,
                                         application: configuration.leasingEntity)
  }
  
  func storePointsCoordinatorDidRequestClose(_ coordinator: StorePointsCoordinator) {
    navigationController.popViewController(animated: true)
  }
}

// MARK: - SelectDeliveryViewModelDelegate
extension DeliveryProductCoordinator: SelectDeliveryViewModelDelegate {
  func selectDeliveryViewModel(_ viewModel: SelectDeliveryViewModel,
                               didRequestCheckPaymentWith leasingEntity: LeasingEntity) {
    showCheckPayment(with: leasingEntity, isPaymentFailed: false)
  }
  
  func selectDeliveryViewModel(_ viewModel: SelectDeliveryViewModel,
                               didFinishWithDelivery paymentURL: URL,
                               leasingEntity: LeasingEntity) {
    configuration.leasingEntity = leasingEntity
    showDeliveryPayment(with: paymentURL, leasingEntity: leasingEntity)
  }
  
  func selectDeliveryViewModelDidRequestReturnToProfile(_ viewModel: SelectDeliveryViewModel) {
    delegate?.deliveryProductCoordinatorDidRequestReturnToProfile(self)
  }
  
  func selectDeliveryViewModel(_ viewModel: SelectDeliveryViewModel,
                               leasingEntity: LeasingEntity,
                               storePoint: StorePointInfo?) {
    showStorePoints(with: leasingEntity, storePoint: storePoint)
  }
  
  func selectDeliveryViewModelDidCancelDelivery(_ viewModel: SelectDeliveryViewModel) {
    delegate?.deliveryProductCoordinatorDidCancelDelivery(self)
  }
}

// MARK: - SelectDeliveryViewControllerDelegate
extension DeliveryProductCoordinator: SelectDeliveryViewControllerDelegate {
  func selectDeliveryViewControllerDidRequestGoBack(_ viewController: SelectDeliveryViewController) {
    delegate?.deliveryProductCoordinatorDidRequestToFinishFlow(self)
  }
}

// MARK: - DeliveryProductPaymentUtilityDelegate
extension DeliveryProductCoordinator: PaymentUtilityDelegate {
  func paymentUtilityDidFail(_ utility: PaymentUtility) {
    showCheckPayment(with: configuration.leasingEntity, isPaymentFailed: true)
  }
  
  func paymentUtilityDidFinishSuccess(_ utility: PaymentUtility) {
    showCheckPayment(with: configuration.leasingEntity, isPaymentFailed: false)
  }
}

// MARK: - CheckPaymentViewModelDelegate
extension DeliveryProductCoordinator: CheckPaymentViewModelDelegate {
  func checkPaymentViewModel(_ viewModel: CheckPaymentViewModel,
                             didRequestRepeatPaymentWithURL url: URL) {
    showDeliveryPayment(with: url, leasingEntity: configuration.leasingEntity)
  }
  
  func checkPaymentViewModelDidFinishSuccess(_ viewModel: CheckPaymentViewModel) {
    showSuccess()
  }
  
  func checkPaymentViewModelDidRequestCheckLater(_ viewModel: CheckPaymentViewModel) {
    delegate?.deliveryProductCoordinatorDidRequestReturnToProfile(self)
  }
  
  func checkPaymentViewModelDidCancelDelivery(_ viewModel: CheckPaymentViewModel) {
    delegate?.deliveryProductCoordinatorDidCancelDelivery(self)
  }
}
