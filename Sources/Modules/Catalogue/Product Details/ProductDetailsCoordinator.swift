//
//  ProductDetailsCoordinator.swift
//  ForwardLeasing
//

import UIKit

protocol ProductDetailsCoordinatorDelegate: class {
  func productDetailsCoordinatorDidRequestToPopToProfile(_ coordinator: ProductDetailsCoordinator)
  func productDetailsCoordinatorDidFinish(_ coordinator: ProductDetailsCoordinator)
  func productDetailsCoordinator(_ coordinator: ProductDetailsCoordinator,
                                 didRequestToExchangeToProduct product: ProductDetails)
}

extension ProductDetailsCoordinatorDelegate {
  func productDetailsCoordinator(_ coordinator: ProductDetailsCoordinator,
                                 didRequestToExchangeToProduct product: ProductDetails) {}
}

struct ProductDetailsCoordinatorConfiguration {
  let bottomButtonType: ProductDetailsBottomButtonType
  let modelCode: String?
}

class ProductDetailsCoordinator: ConfigurableNavigationFlowCoordinator {
  typealias Configuration = ProductDetailsCoordinatorConfiguration
  // MARK: - Properties
  
  let appDependency: AppDependency
  let navigationObserver: NavigationObserver
  let navigationController: NavigationController
  var childCoordinators: [BaseCoordinator] = []
  var onDidFinish: (() -> Void)?

  weak var delegate: ProductDetailsCoordinatorDelegate?
  
  private var onDidRequestPopToInitialScreen: (() -> Void)?
  
  private let configuration: ProductDetailsCoordinatorConfiguration
  
  // MARK: - Init
  
  required init(appDependency: AppDependency,
                navigationController: NavigationController,
                navigationObserver: NavigationObserver,
                configuration: Configuration) {
    self.navigationController = navigationController
    self.navigationObserver = navigationObserver
    self.appDependency = appDependency
    self.configuration = configuration
  }

  // MARK: - Navigation

  func start(animated: Bool) {
    showProductDetailsScreen(animated: animated)
  }
  
  private func showProductDetailsScreen(animated: Bool) {
    let input = ProductDetailsViewModelInput(bottomButtonType: configuration.bottomButtonType,
                                             modelCode: configuration.modelCode)
    let viewModel = ProductDetailsViewModel(dependencies: appDependency,
                                            input: input)
    viewModel.delegate = self
    let viewController = ProductDetailsViewController(viewModel: viewModel)
    viewController.delegate = self
    viewController.navigationItem.titleView = viewController.createTitleView()
    navigationController.pushViewController(viewController, animated: true)
    navigationObserver.addObserver(self, forPopOf: viewController)
  }
  
  private func showWebViewScreen(url: URL?, title: String?) {
    guard let url = url else { return }
    let viewController = WebViewController(url: url)
    viewController.title = title
    navigationController.pushViewController(viewController, animated: true)
  }

  private func showCreateLeasingApplicationScreen(for product: LeasingProductInfo, basketID: String) {
    let coordinator = show(CreateApplicationCoordinator.self, configuration: .new(product: product, basketID: basketID),
                           animated: true)
    coordinator.delegate = self
  }
}

// MARK: - ProductDetailsViewModelDelegate

extension ProductDetailsCoordinator: ProductDetailsViewModelDelegate {
  func productDetailsViewModel(_ viewModel: ProductDetailsViewModel, didRequestToOpenURL url: URL?,
                               title: String?) {
    showWebViewScreen(url: url, title: title)
  }

  func productDetailsViewModel(_ viewModel: ProductDetailsViewModel, didRequestToBuyProduct product: LeasingProductInfo,
                               basketID: String) {
    showCreateLeasingApplicationScreen(for: product, basketID: basketID)
  }
  
  func productDetailsViewModel(_ viewModel: ProductDetailsViewModel, didRequestToExchangeProduct product: ProductDetails) {
    delegate?.productDetailsCoordinator(self, didRequestToExchangeToProduct: product)
  }
}

// MARK: - CreateApplicationCoordinatorDelegate

extension ProductDetailsCoordinator: CreateApplicationCoordinatorDelegate {
  func createApplicationCoordinator(_ coordinator: CreateApplicationCoordinator, didSign contract: LeasingEntity) {
    // do nothing
  }

  func createApplicationCoordinatorDidRequestToPopToProfile(_ coordinator: CreateApplicationCoordinator) {
    delegate?.productDetailsCoordinatorDidRequestToPopToProfile(self)
  }
}

// MARK: - ProductDetailsViewControllerDelegate

extension ProductDetailsCoordinator: ProductDetailsViewControllerDelegate {
  func productDetailsViewControllerDidFinish(_ viewController: ProductDetailsViewController) {
    delegate?.productDetailsCoordinatorDidFinish(self)
  }
}
