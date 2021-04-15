//
//  TabBarCoordinator.swift
//  ForwardLeasing
//

import UIKit

enum TabKind: Int {
  case catalogue, profile
}

struct WeakCoordinatorWrapper {
  weak var value: NavigationFlowCoordinator?
  weak var navigationObserver: NavigationObserver?
  
  init (value: NavigationFlowCoordinator, navigationObserver: NavigationObserver?) {
    self.value = value
    self.navigationObserver = navigationObserver
  }
}

protocol TabBarCoordinatorDelegate: class {
  func tabBarCoordinatorDidFinish(_ coordinator: TabBarCoordinator)
  func tabBarCoordinatorDidShowMajorAppUpdateScreen(_ coordinator: TabBarCoordinator)
  func tabBarCoordinatorDidCloseMajorAppUpdateScreen(_ coordinator: TabBarCoordinator)
}

struct DeeplinkActions {
  var onDidRequestOpenProductDetails: ((String) -> Void)?
  var onDidRequestOpenCategory: ((String) -> Void)?
  var onDidRequestOpenProfile: (() -> Void)?
  var onDidRequestOpenContractDetails: ((String) -> Void)?
}

class TabBarCoordinator: NSObject, ConfigurableNavigationFlowCoordinator {
  typealias Configuration = Void
  
  // MARK: - Properties
  
  weak var delegate: TabBarCoordinatorDelegate?
  
  let appDependency: AppDependency
  let navigationObserver: NavigationObserver
  let navigationController: NavigationController
  
  var childCoordinators: [BaseCoordinator] = []
  var onDidFinish: (() -> Void)?
  
  private var tabCoordinators: [TabKind: WeakCoordinatorWrapper] = [:]
  private var activeTab: TabKind = .catalogue
  private var onNeedsToPopControllers: (() -> Void)?
  private var onNeedsToSwitchToTab: ((TabKind) -> Void)?
  private var deeplinkActions = DeeplinkActions()
  private var deeplink: DeeplinkType?
  
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
    showTabs(animated: animated)
  }
  
  func openDeeplink(_ deeplink: DeeplinkType) {
    switch deeplink {
    case .category(let categoryCode):
      deeplinkActions.onDidRequestOpenCategory?(categoryCode)
    case .contractDetails(let contractID):
      deeplinkActions.onDidRequestOpenContractDetails?(contractID)
    case .productDetails(let goodCode):
      deeplinkActions.onDidRequestOpenProductDetails?(goodCode)
    case .profile:
      deeplinkActions.onDidRequestOpenProfile?()
    }
  }

  private func showTabs(animated: Bool) {
    navigationController.setNavigationBarHidden(true, animated: false)

    let catalogueNavigationController = createCatalogueNavigationController()
    let profileNavigationController = createProfileNavigationController()
    
    let tabBarController = TabBarViewController()
    tabBarController.viewControllers = [catalogueNavigationController,
                                        profileNavigationController]
    tabBarController.delegate = self
    
    onNeedsToPopControllers = { [weak catalogueNavigationController, weak profileNavigationController] in
      [catalogueNavigationController, profileNavigationController].forEach {
        $0?.presentedViewController?.dismiss(animated: false)
        $0?.popToRootViewController(animated: false)
      }
    }
    
    onNeedsToSwitchToTab = { [weak self, weak tabBarController] tab in
      self?.onNeedsToPopControllers?()
      tabBarController?.selectedIndex = tab.rawValue
      self?.activeTab = tab
    }
    
    navigationController.pushViewController(tabBarController, animated: animated)
  }
  
  // MARK: - Create View Controllers
  
  private func createCatalogueNavigationController() -> NavigationController {
    let navController = NavigationController()
    let item = UITabBarItem(title: R.string.tabBar.catalogueTab(),
                            image: R.image.catalogueTabIcon()?.withRenderingMode(.alwaysOriginal),
                            selectedImage: R.image.selectedCatalogueTabIcon()?.withRenderingMode(.alwaysOriginal))
    navController.tabBarItem = item
    navController.configureNavigationBarAppearance()
    let catalogueNavigationObserver = NavigationObserver(navigationController: navController)
    let coordinator = CatalogueCoordinator(appDependency: appDependency,
                                           navigationController: navController,
                                           navigationObserver: catalogueNavigationObserver,
                                           configuration: ())
    
    deeplinkActions.onDidRequestOpenCategory = { [weak coordinator, weak self] categoryCode in
      self?.onNeedsToSwitchToTab?(.catalogue)
      coordinator?.showCategoryDetailsScreen(categoryID: categoryCode)
    }
    deeplinkActions.onDidRequestOpenProductDetails = { [weak coordinator, weak self] goodCode in
      self?.onNeedsToSwitchToTab?(.catalogue)
      coordinator?.showProductDetailsScreen()
    }
    coordinator.delegate = self
    add(child: coordinator)
    coordinator.start(animated: false)
    tabCoordinators[.catalogue] = WeakCoordinatorWrapper(value: coordinator,
                                                         navigationObserver: catalogueNavigationObserver)
    return navController
  }
  
  private func createProfileNavigationController() -> NavigationController {
    let navController = NavigationController()
    let item = UITabBarItem(title: R.string.tabBar.profileTab(),
                            image: R.image.profileTabIcon()?.withRenderingMode(.alwaysOriginal),
                            selectedImage: R.image.selectedProfileTabIcon()?.withRenderingMode(.alwaysOriginal))
    navController.tabBarItem = item
    navController.configureNavigationBarAppearance()
    let profileNavigationObserver = NavigationObserver(navigationController: navController)
    let coordinator = ProfileCoordinator(appDependency: appDependency,
                                         navigationController: navController,
                                         navigationObserver: profileNavigationObserver,
                                         configuration: ())
    deeplinkActions.onDidRequestOpenProfile = { [weak self] in
      self?.onNeedsToSwitchToTab?(.profile)
    }
    deeplinkActions.onDidRequestOpenContractDetails = { [weak coordinator, weak self] applicationID in
      self?.onNeedsToSwitchToTab?(.profile)
      coordinator?.showContractDetails(applicationID: applicationID)
    }
    add(child: coordinator)
    coordinator.start(animated: false)
    tabCoordinators[.profile] = WeakCoordinatorWrapper(value: coordinator,
                                                       navigationObserver: profileNavigationObserver)
    return navController
  }
}

// MARK: - UITabBarControllerDelegate

extension TabBarCoordinator: UITabBarControllerDelegate {
  func tabBarController(_ tabBarController: UITabBarController,
                        didSelect viewController: UIViewController) {
    let tabBarIndex = tabBarController.selectedIndex
    if let tab = TabKind(rawValue: tabBarIndex) {
      activeTab = tab
    }
  }
}

// MARK: - CatalogueCoordinatorDelegate

extension TabBarCoordinator: CatalogueCoordinatorDelegate {
  func catalogueCoordinatorDidRequestToPopToProfile(_ coordinator: CatalogueCoordinator) {
    onNeedsToSwitchToTab?(.profile)
  }
}
