//
//  CategoryDetailsCoordinator.swift
//  ForwardLeasing
//

import UIKit

struct CategoryDetailsCoordinatorConfiguration {
  let category: Category
  let subcategory: Subcategory?
}

protocol CategoryDetailsCoordinatorDelegate: class {
  func categoryDetailsCoordinatorDidRequestToPopToProfile(_ coordinator: CategoryDetailsCoordinator)
}

enum CategoryDetailsFlow {
  case link(categoryCode: String)
  case `default`(configuration: CategoryDetailsCoordinatorConfiguration)
  
  var categoryCode: String {
    switch self {
    case .default(let configuration):
      return configuration.category.code
    case .link(let categoryCode):
      return categoryCode
    }
  }
  
  var category: Category? {
    switch self {
    case .default(let configuration):
      return configuration.category
    default:
      return nil
    }
  }
}

class CategoryDetailsCoordinator: ConfigurableNavigationFlowCoordinator {
  typealias Configuration = CategoryDetailsFlow
  // MARK: - Properties
  
  let appDependency: AppDependency
  let navigationObserver: NavigationObserver
  let navigationController: NavigationController
  var childCoordinators: [BaseCoordinator] = []
  var onDidFinish: (() -> Void)?

  weak var delegate: CategoryDetailsCoordinatorDelegate?
  
  private let flow: Configuration

  private var onDidSelectSubcategory: ((Subcategory?) -> Void)?
  private var onDidUpdateFilters: (([Filter], [ColorFilter]) -> Void)?
  private var onDidRequestHideBottomSheet: (() -> Void)?
  
  // MARK: - Init
  
  required init(appDependency: AppDependency,
                navigationController: NavigationController,
                navigationObserver: NavigationObserver,
                configuration: Configuration) {
    self.navigationController = navigationController
    self.navigationObserver = navigationObserver
    self.appDependency = appDependency
    self.flow = configuration
  }
  
  // MARK: - Navigation
  
  func start(animated: Bool) {
    showCategoryDetailsScreen(animated: animated)
  }
  
  private func showCategoryDetailsScreen(animated: Bool) {
    let viewModel = CategoryDetailsViewModel(flow: flow)
    viewModel.delegate = self
    onDidSelectSubcategory = { [weak viewModel] subcategory in
      viewModel?.update(selectedSubcategory: subcategory)
    }
    onDidUpdateFilters = { [weak viewModel, weak self] filters, colorFilters in
      viewModel?.update(filters: filters, colorFilters: colorFilters)
      self?.onDidRequestHideBottomSheet?()
    }
    let viewController = CategoryDetailsViewController(viewModel: viewModel)
    viewController.navigationItem.title = viewModel.screenTitle
    viewController.delegate = self
    navigationController.pushViewController(viewController, animated: true)
    navigationObserver.addObserver(self, forPopOf: viewController)
  }
  
  private func showProductDetailsScreen() {
    let configuration = ProductDetailsCoordinatorConfiguration(bottomButtonType: .order, modelCode: nil)
    let coordintator = show(ProductDetailsCoordinator.self, configuration: configuration, animated: true)
    coordintator.delegate = self
  }

  private func showSelectSubcategorysScreen(subcategories: [Subcategory], selectedSubcategory: Subcategory?) {
    let viewModel = SelectSubcategoryViewModel(subcategories: subcategories, selectedSubcategory: selectedSubcategory)
    viewModel.delegate = self
    let viewController = SelectSubcategoryViewController(viewModel: viewModel)
    navigationController.topViewController?.addBottomSheetViewController(withDarkView: true,
                                                                         viewController: viewController,
                                                                         initialAnchorPointOffset: viewController.height,
                                                                         height: viewController.height,
                                                                         animated: true)
  }

  private func showChangeFiltesrScreen(filters: [Filter], colorFilters: [ColorFilter]) {
    let viewModel = SubcategoryFiltersViewModel(filters: filters, colorFilters: colorFilters)
    viewModel.delegate = self
    let viewController = SubcategoryFiltersViewController(viewModel: viewModel)
    onDidRequestHideBottomSheet = { [weak viewController] in
      viewController?.removeBottomSheetViewController(animated: true)
    }
    let initialOffset = UIScreen.main.bounds.height - (14 + UIApplication.shared.statusBarFrame.height)
    navigationController.topViewController?.addBottomSheetViewController(withDarkView: true,
                                                                         viewController: viewController,
                                                                         initialAnchorPointOffset: initialOffset,
                                                                         animated: true)
  }
}

// MARK: - CategoryDetailsViewModelDelegate

extension CategoryDetailsCoordinator: CategoryDetailsViewModelDelegate {
  func categoryDetailsViewModel(_ viewModel: CategoryDetailsViewModel, didRequestShowProductDetails product: Product) {
    showProductDetailsScreen()
  }

  func categoryDetailsViewModel(_ viewModel: CategoryDetailsViewModel,
                                didRequestSelectSubcategory currentSubcategory: Subcategory?, allSubcategories: [Subcategory]) {
    showSelectSubcategorysScreen(subcategories: allSubcategories, selectedSubcategory: currentSubcategory)
  }

  func categoryDetailsViewModel(_ viewModel: CategoryDetailsViewModel, didRequestChangeFilters filters: [Filter],
                                colorFilters: [ColorFilter]) {
    showChangeFiltesrScreen(filters: filters, colorFilters: colorFilters)
  }
}

// MARK: - CategoryDetailsViewControllerDelegate

extension CategoryDetailsCoordinator: CategoryDetailsViewControllerDelegate {
  func categoryDetailsViewControllerDidFinish(_ viewController: CategoryDetailsViewController) {
    navigationController.popViewController(animated: true)
  }
}

// MARK: - SelectSubcategoryViewModelDelegate

extension CategoryDetailsCoordinator: SelectSubcategoryViewModelDelegate {
  func selectSubcategoryViewModel(_ viewModel: SelectSubcategoryViewModel, didSelectSubcategory subcategory: Subcategory?) {
    onDidSelectSubcategory?(subcategory)
  }
}

// MARK: - SubcategoryFiltersViewModelDelegate

extension CategoryDetailsCoordinator: SubcategoryFiltersViewModelDelegate {
  func subcategoryFiltersViewModel(_ viewModel: SubcategoryFiltersViewModel, didFinishWithFilters filters: [Filter],
                                   colorFilters: [ColorFilter]) {
    onDidUpdateFilters?(filters, colorFilters)
  }
}

// MARK: - ProductDetailsCoordinatorDelegate

extension CategoryDetailsCoordinator: ProductDetailsCoordinatorDelegate {
  func productDetailsCoordinatorDidFinish(_ coordinator: ProductDetailsCoordinator) {
    navigationController.popViewController(animated: true)
    onDidFinish?()
  }

  func productDetailsCoordinatorDidRequestToPopToProfile(_ coordinator: ProductDetailsCoordinator) {
    delegate?.categoryDetailsCoordinatorDidRequestToPopToProfile(self)
  }
}
