//
//  AuthCoordinator.swift
//  ForwardLeasing
//

import UIKit

protocol AuthCoordinatorDelegate: class {
  func authCoordinatorDidSignIn(_ coordinator: AuthCoordinator)
}

class AuthCoordinator: ConfigurableNavigationFlowCoordinator {
  typealias Configuration = Void
  // MARK: - Properties
  
  let appDependency: AppDependency
  let navigationObserver: NavigationObserver
  let navigationController: NavigationController
  var childCoordinators: [BaseCoordinator] = []
  var onDidFinish: (() -> Void)?
  private var rootController: UIViewController?
  
  weak var delegate: AuthCoordinatorDelegate?
  
  // MARK: - Init
  
  required init(appDependency: AppDependency,
                navigationController: NavigationController,
                navigationObserver: NavigationObserver,
                configuration: Configuration) {
    self.navigationController = navigationController
    self.navigationObserver = navigationObserver
    self.appDependency = appDependency
  }
  
  // MARK: - Public Methods
  
  func start(animated: Bool) {
    showAuthorizationScreen(animated: animated)
  }
  
  // MARK: - Private Methods
  private func showAuthorizationScreen(animated: Bool) {
    let viewModel = AuthorizationViewModel(dependencies: appDependency)
    viewModel.delegate = self
    
    let settingsButton = NavBarButton(image: R.image.settingsButtonWithBackground()) { [weak self] in
      self?.showSettingsScreen()
    }
    
    let viewController = AuthorizationViewController(viewModel: viewModel)
    viewController.hidesBottomBarWhenPushed = false
    viewController.navigationBarView.configureNavigationBarTitle(title: R.string.authorization.screenTitle(),
                                                                 rightViews: [settingsButton])
    
    navigationController.pushViewController(viewController, animated: animated)
    navigationObserver.addObserver(self, forPopOf: viewController)
  }
  
  private func showPinCodeRecovery() {
    let viewModel = PinCodeRecoveryViewModel(dependencies: appDependency)
    viewModel.delegate = self
    let controller = PinCodeRecoveryViewController(viewModel: viewModel)
    rootController = controller
    controller.delegate = self
    navigationController.pushViewController(controller, animated: true)
  }
  
  private func showRegister() {
    let viewModel = RegisterViewModel(dependencies: appDependency)
    viewModel.delegate = self
    let controller = RegisterViewController(viewModel: viewModel)
    controller.delegate = self
    rootController = controller
    navigationController.pushViewController(controller, animated: true)
  }
  
  private func showPhoneConfirmationViewController(with sessionID: String, isPinRecovery: Bool) {
    let strategyType: PhoneConfirmStrategyType = .pin(dependency: appDependency,
                                                      sessionID: sessionID,
                                                      type: isPinRecovery ? .pinRecovery : .registration)
    let viewModel = PhoneConfirmationViewModel(dependencies: appDependency,
                                               strategyType: strategyType)
    viewModel.delegate = self
    let controller = PhoneConfirmationViewController(viewModel: viewModel)
    controller.delegate = self
    navigationController.pushViewController(controller, animated: true)
  }
  
  private func showPinCodeConfirmViewController(with sessionID: String, type: PinCodeConfirmationType) {
    let viewModel = PinCodeConfirmViewModel(dependency: appDependency,
                                            sessionID: sessionID, type: type)
    viewModel.delegate = self
    let controller = PinCodeConfirmViewController(viewModel: viewModel)
    controller.delegate = self
    navigationController.pushViewController(controller, animated: true)
  }
  
  private func showSettingsScreen() {
    show(ProfileSettingsCoordinator.self, configuration: ProfileSettingsFlow.notAuthorized, animated: true)
  }
  
  private func showAgreement(with url: URL) {
    let controller = WebViewController(url: url)
    navigationController.pushViewController(controller, animated: true)
  }
  
  private func popToRootController() {
    if let controller = rootController {
      navigationController.popToViewController(controller, animated: true)
    }
  }
}

// MARK: - RegisterViewModelDelegate
extension AuthCoordinator: RegisterViewModelDelegate {
  func registerViewModel(_ viewModel: RegisterViewModel, didRequestOpeURL url: URL) {
    showAgreement(with: url)
  }
  
  func registerViewModel(_ viewModel: RegisterViewModel, didFinishWithSessionID sessionID: String) {
    showPhoneConfirmationViewController(with: sessionID, isPinRecovery: false)
  }
}

// MARK: - PhoneConfirmationViewModel
extension AuthCoordinator: PhoneConfirmationViewModelDelegate {
  func phoneConfirmationViewModel(_ viewModel: PhoneConfirmationViewModel,
                                  didConfirmRegisterOTPWithSessionID sessionID: String,
                                  withPinCodeConfirmationType type: PinCodeConfirmationType){
    showPinCodeConfirmViewController(with: sessionID, type: type)
  }
}

// MARK: - PhoneConfirmationViewControllerDelegate
extension AuthCoordinator: PhoneConfirmationViewControllerDelegate {
  func phoneConfirmationViewControllerDidRequestGoBack(_ viewController: PhoneConfirmationViewController) {
    popToRootController()
  }
}

// MARK: - PinCodeConfirmViewControllerDelegate
extension AuthCoordinator: PinCodeConfirmViewControllerDelegate {
  func pinCodeConfirmViewControllerDidRequestGoBack(_ viewController: PinCodeConfirmViewController) {
    popToRootController()
  }
}

extension AuthCoordinator: PinCodeRecoveryViewModelDelegate {
// MARK: - PinCodeRecoveryViewModelDelegate
  func pinCodeRecoveryViewModel(_ viewModel: PinCodeRecoveryViewModel, didRequestRecoveryForSessionID sessionID: String) {
    showPhoneConfirmationViewController(with: sessionID, isPinRecovery: true)
  }
}

// MARK: - PinCodeRecoveryViewControllerDelegate
extension AuthCoordinator: PinCodeRecoveryViewControllerDelegate {
  func pinCodeRecoveryViewControllerDidRequestGoBack(_ viewController: PinCodeRecoveryViewController) {
    navigationController.popViewController(animated: true)
  }
}

// MARK: - RegisterViewControllerDelegate
extension AuthCoordinator: RegisterViewControllerDelegate {
  func registerViewControllerDidRequestGoBack(_ viewController: RegisterViewController) {
    navigationController.popViewController(animated: true)
  }
}

// MARK: - AuthorizationViewModelDelegate
extension AuthCoordinator: AuthorizationViewModelDelegate {
  func authorizationViewModelDidSignIn(_ viewModel: AuthorizationViewModel) {
    delegate?.authCoordinatorDidSignIn(self)
  }
  
  func authorizationViewModelDidRequestToSignUp(_ viewModel: AuthorizationViewModel) {
    showRegister()
  }
  
  func authorizationViewModelDidRequestToResetPassword(_ viewModel: AuthorizationViewModel) {
    showPinCodeRecovery()
  }
}

// MARK: - PinCodeConfirmViewModelDelegate
extension AuthCoordinator: PinCodeConfirmViewModelDelegate {
  func pinCodeConfirmViewModelDidFinish(_ viewModel: PinCodeConfirmViewModel) {
    delegate?.authCoordinatorDidSignIn(self)
  }
}
