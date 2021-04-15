//
//  MainCoordinator.swift
//  ForwardLeasing
//

import UIKit

class MainCoordinator: NavigationFlowCoordinator {
  // MARK: - Properties
  
  private let window: UIWindow
  private var rootNavigationController: NavigationController
  private (set) var navigationObserver: NavigationObserver
  
  let appDependency: AppDependency
  let utility: MainCoordinatorUtility
  
  var childCoordinators: [BaseCoordinator] = []
  var onDidFinish: (() -> Void)?
  
  private var onDidRequestOpenDeeplink: ((DeeplinkType) -> Void)?
  
  var topController: UIViewController {
    if let lastChild = topCoordinator {
      return lastChild.topController
    }
    var controller: UIViewController = rootNavigationController
    while let presentedController = controller.presentedViewController {
      controller = presentedController
    }
    return controller
  }
  
  var navigationController: NavigationController {
    return rootNavigationController
  }
  
  // MARK: - Init
  required init(window: UIWindow, utility: MainCoordinatorUtility, appDependency: AppDependency) {
    self.window = window
    self.appDependency = appDependency
    self.utility = utility
    rootNavigationController = NavigationController()
    navigationObserver = NavigationObserver(navigationController: rootNavigationController)
    window.rootViewController = rootNavigationController
    if #available(iOS 13.0, *) {
      window.overrideUserInterfaceStyle = .light
    }
    
    utility.delegate = self
  }
  
  // MARK: - Navigation
  
  func start(animated: Bool) {
    window.makeKeyAndVisible()
    rootNavigationController.configureNavigationBarAppearance()
    utility.start()
    showStartScreen(animated: true)
  }
  
  private func showStartScreen(animated: Bool) {
    let coordinator = show(TabBarCoordinator.self, configuration: (), animated: false)
    onDidRequestOpenDeeplink = { [weak coordinator] deeplink in
      coordinator?.openDeeplink(deeplink)
    }
  }
  
  private func showNewApplicationVersionAlert(message: String?, isCritical: Bool, completion: (() -> Void)?) {
    let alertController = BaseAlertViewController(closesOnBackgroundTap: false)
    let popup = PopupAlertView(message)
    
    let updateButton = StandardButton(type: .primary)
    updateButton.setTitle(R.string.common.update(), for: .normal)
    updateButton.actionHandler(controlEvents: .touchUpInside) {
      guard let url = Constants.appStoreURL else { return }
      UIApplication.shared.open(url)
    }
    popup.addButton(updateButton)
    
    if !isCritical {
      let closeButton = StandardButton(type: .secondary)
      closeButton.setTitle(R.string.common.close(), for: .normal)
      closeButton.actionHandler(controlEvents: .touchUpInside) { [weak alertController] in
        alertController?.dismiss(animated: true, completion: completion)
      }
      popup.addButton(closeButton)
    }
    
    alertController.addPopupAlert(popup)
    navigationController.present(alertController, animated: true, completion: nil)
  }
  
  private func showInformationAlert(message: String?, isCritical: Bool) {
    let alertController = BaseAlertViewController(closesOnBackgroundTap: false)
    let popup = PopupAlertView(message)
    
    if !isCritical {
      let okButton = StandardButton(type: .primary)
      okButton.setTitle(R.string.common.ok(), for: .normal)
      okButton.actionHandler(controlEvents: .touchUpInside) { [weak alertController] in
        alertController?.dismiss(animated: true, completion: nil)
      }
      popup.addButton(okButton)
    }
    
    alertController.addPopupAlert(popup)
    navigationController.present(alertController, animated: true, completion: nil)
  }
}

// MARK: - MainCoordinatorUtilityDelegate

extension MainCoordinator: MainCoordinatorUtilityDelegate {
  func deeplinkService(_ utility: MainCoordinatorUtility, didRequestOpenDeeplink deeplink: DeeplinkType) {
    onDidRequestOpenDeeplink?(deeplink)
  }
  
  func mainCoordinatorUtility(_ utility: MainCoordinatorUtility,
                              didRequestToShowNewVersionAlertWithMessage message: String?,
                              isCritical: Bool, completion: (() -> Void)?) {
    showNewApplicationVersionAlert(message: message, isCritical: isCritical, completion: completion)
  }
  
  func mainCoordinatorUtility(_ utility: MainCoordinatorUtility,
                              didRequestToShowInformationAlertWithMessage message: String?,
                              isCritical: Bool) {
    showInformationAlert(message: message, isCritical: isCritical)
  }
}
