//
//  Catalogueoordinator.swift
//  ForwardLeasing
//

import UIKit

protocol CatalogueCoordinatorDelegate: class {
  func catalogueCoordinatorDidRequestToPopToProfile(_ coordinator: CatalogueCoordinator)
}

class CatalogueCoordinator: ConfigurableNavigationFlowCoordinator {
  typealias Configuration = Void
  // MARK: - Properties
  
  let appDependency: AppDependency
  let navigationObserver: NavigationObserver
  let navigationController: NavigationController
  var childCoordinators: [BaseCoordinator] = []
  var onDidFinish: (() -> Void)?

  weak var delegate: CatalogueCoordinatorDelegate?
  
  // MARK: - Init
  
  required init(appDependency: AppDependency,
                navigationController: NavigationController,
                navigationObserver: NavigationObserver,
                configuration: Configuration) {
    self.navigationController = navigationController
    self.navigationObserver = navigationObserver
    self.appDependency = appDependency
  }

  // MARK: - Navigation
  
  func start(animated: Bool) {
    showCatalogueScreen(animated: animated)
  }
  
  func showCategoryDetailsScreen(categoryID: String) {
    let flow = CategoryDetailsFlow.link(categoryCode: categoryID)
    let coordinator = show(CategoryDetailsCoordinator.self, configuration: flow, animated: true)
    coordinator.delegate = self
  }
  
  func showProductDetailsScreen() {
    // TODO: - Remove Stub
    let configuration = ProductDetailsCoordinatorConfiguration(bottomButtonType: .order, modelCode: nil)
    let coordinator = show(ProductDetailsCoordinator.self, configuration: configuration, animated: true)
    coordinator.delegate = self
  }
  
  private func showCatalogueScreen(animated: Bool) {
    let viewModel = CatalogueViewModel(dependencies: appDependency)
    viewModel.delegate = self
    let viewController = CatalogueViewController(viewModel: viewModel)
    viewController.navigationItem.title = R.string.catalogue.screenTitle()
    navigationController.pushViewController(viewController, animated: animated)
    navigationObserver.addObserver(self, forPopOf: viewController)
  }
  
  private func showCategoryDetailsScreen(category: Category, subcategory: Subcategory?) {
    let config = CategoryDetailsCoordinatorConfiguration(category: category, subcategory: subcategory)
    let flow = CategoryDetailsFlow.default(configuration: config)
    let coordinator = show(CategoryDetailsCoordinator.self, configuration: flow, animated: true)
    coordinator.delegate = self
  }
  
  private func showBuySubscription(name: String, subscriptionItem: SubscriptionProductItem) {
    let configuration = BuySubscriptionConfiguration(name: name, subscriptionItemID: subscriptionItem.id,
                                                     selectedCard: .new, saveCard: false, flow: .catalogue)
    let coordinator = show(BuySubscriptionCoordinator.self, configuration: configuration, animated: true)
    coordinator.delegate = self
  }
}

// MARK: - CatalogueViewModelDelegate

extension CatalogueCoordinator: CatalogueViewModelDelegate {
  func catalogueViewModel(_ viewModel: CatalogueViewModel,
                          didSelectSubscriptionProduct subscriptionProduct: SubscriptionProduct,
                          withSubcriptionItem subscriptionItem: SubscriptionProductItem) {
    showBuySubscription(name: subscriptionProduct.name, subscriptionItem: subscriptionItem)
  }
  
  func catalogueViewModel(_ viewModel: CatalogueViewModel, didRequestShowCategoryDetails category: Category,
                          subcategory: Subcategory?) {
    showCategoryDetailsScreen(category: category, subcategory: subcategory)
  }

  func catalogueViewModel(_ viewModel: CatalogueViewModel, didRequestShowProductDetails product: Product) {
    showProductDetailsScreen()
  }
}

// MARK: - ProductDetailsCoordinatorDelegate

extension CatalogueCoordinator: ProductDetailsCoordinatorDelegate {
  func productDetailsCoordinatorDidFinish(_ coordinator: ProductDetailsCoordinator) {
    navigationController.popViewController(animated: true)
  }

  func productDetailsCoordinatorDidRequestToPopToProfile(_ coordinator: ProductDetailsCoordinator) {
    delegate?.catalogueCoordinatorDidRequestToPopToProfile(self)
  }
}

// MARK: - CategoryDetailsCoordinatorDelegate

extension CatalogueCoordinator: CategoryDetailsCoordinatorDelegate {
  func categoryDetailsCoordinatorDidRequestToPopToProfile(_ coordinator: CategoryDetailsCoordinator) {
    delegate?.catalogueCoordinatorDidRequestToPopToProfile(self)
  }
}

// MARK: - BuySubscriptionCoordinatorDelegate
extension CatalogueCoordinator: BuySubscriptionCoordinatorDelegate {
  func buySubscriptionCoordinatorDidRequestPopToCatalogue(_ coordinator: BuySubscriptionCoordinator) {
    popToController(CatalogueViewController.self)
  }
}
