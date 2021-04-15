//
//  ProfileSettingsCoordinator.swift
//  ForwardLeasing
//

import UIKit
import MessageUI

class ProfileSettingsCoordinator: NSObject, ConfigurableNavigationFlowCoordinator {
  typealias Configuration = ProfileSettingsFlow
  // MARK: - Properties
  let appDependency: AppDependency
  let navigationObserver: NavigationObserver
  let navigationController: NavigationController
  var childCoordinators: [BaseCoordinator] = []
  var onDidFinish: (() -> Void)?
  
  private var onDidFailSendEmail: ((Error) -> Void)?
  private let flow: ProfileSettingsFlow
  
  // MARK: - Init
  
  required init(appDependency: AppDependency,
                navigationController: NavigationController,
                navigationObserver: NavigationObserver,
                configuration: Configuration) {
    self.navigationController = navigationController
    self.navigationObserver = navigationObserver
    self.appDependency = appDependency
    self.flow = configuration
    super.init()
  }
  
  // MARK: - Public Methods
  func start(animated: Bool) {
    showProfileSettings()
  }
  
  // MARK: - Private Methods
  private func showProfileSettings() {
    let viewModel = ProfileSettingsViewModel(dependencies: appDependency,
                                             flow: appDependency.userDataStore.isLoggedIn ? .authorized : .notAuthorized)
    viewModel.delegate = self
    let controller = ProfileSettingsViewController(viewModel: viewModel)
    controller.delegate = self
    navigationController.pushViewController(controller, animated: true)
    onDidFailSendEmail = { [weak navigationController] error in
      navigationController?.showErrorBanner(error: error)
    }
    navigationObserver.addObserver(self, forPopOf: controller)
  }
  
  private func showUpdatePinPhoneConfirmation(with sessionID: String) {
    let strategyType: PhoneConfirmStrategyType = .pin(dependency: appDependency,
                                                      sessionID: sessionID, type: .pinUpdate)
    let viewModel = PhoneConfirmationViewModel(dependencies: appDependency,
                                               strategyType: strategyType)
    viewModel.delegate = self
    let controller = PhoneConfirmationViewController(viewModel: viewModel)
    controller.delegate = self
    navigationController.pushViewController(controller, animated: true)
  }
  
  private func showUpdatePinCode(with sessionID: String) {
    let viewModel = PinCodeConfirmViewModel(dependency: appDependency,
                                            sessionID: sessionID, type: .pinUpdate)
    viewModel.delegate = self
    let controller = PinCodeConfirmViewController(viewModel: viewModel)
    controller.delegate = self
    navigationController.pushViewController(controller, animated: true)
  }
  
  private func showEmail(withTheme theme: String, body: String, to email: String) {
    guard MFMailComposeViewController.canSendMail() else { return }
    let controller = MFMailComposeViewController()
    controller.mailComposeDelegate = self
    controller.setSubject(theme)
    controller.setMessageBody(body, isHTML: false)
    controller.setToRecipients([email])
    navigationController.present(controller, animated: true, completion: nil)
  }
  
  private func showWebView(with url: URL) {
    let controller = WebViewController(url: url)
    navigationController.pushViewController(controller, animated: true)
  }
  
  private func showAboutApp() {
    let controller = AboutAppViewController()
    navigationController.pushViewController(controller, animated: true)
  }
}

// MARK: - ProfileSettingsViewModelDelegate
extension ProfileSettingsCoordinator: ProfileSettingsViewModelDelegate {
  func profileSettingsViewModelDidRequestAboutApp(_ viewModel: ProfileSettingsViewModel) {
    showAboutApp()
  }
  
  func profileSettingsViewModel(_ viewModel: ProfileSettingsViewModel, didRequestShowDocumentWithURL url: URL) {
    showWebView(with: url)
  }
  
  func profileSettingsViewModel(_ viewModel: ProfileSettingsViewModel, didRequestContactViaEmailWithTheme theme: String,
                                body: String, to email: String) {
    showEmail(withTheme: theme, body: body, to: email)
  }
  
  func profileSettingsViewModel(_ viewModel: ProfileSettingsViewModel,
                                didRequestUpdatePinCodeWithSessionID sessionID: String) {
    showUpdatePinPhoneConfirmation(with: sessionID)
  }
  
  func profileSettingsViewModelDidRequestLogout(_ viewModel: ProfileSettingsViewModel) {
    appDependency.logoutHandler?.logOut()
  }
}

// MARK: - ProfileSettingViewControllerDelegate
extension ProfileSettingsCoordinator: ProfileSettingViewControllerDelegate {
  func profileSettingsViewControllerDidRequestGoBack(_ viewController: ProfileSettingsViewController) {
    navigationController.popViewController(animated: true)
  }
}

// MARK: - PhoneConfirmationViewModelDelegate
extension ProfileSettingsCoordinator: PhoneConfirmationViewModelDelegate {
  func phoneConfirmationViewModel(_ viewModel: PhoneConfirmationViewModel,
                                  didConfirmRegisterOTPWithSessionID sessionID: String,
                                  withPinCodeConfirmationType type: PinCodeConfirmationType) {
    guard type == .pinUpdate else { return }
    showUpdatePinCode(with: sessionID)
  }
}

// MARK: - PhoneConfirmationViewControllerDelegate
extension ProfileSettingsCoordinator: PhoneConfirmationViewControllerDelegate {
  func phoneConfirmationViewControllerDidRequestGoBack(_ viewController: PhoneConfirmationViewController) {
    navigationController.popViewController(animated: true)
  }
}

// MARK: - PinCodeConfirmViewModelDelegate
extension ProfileSettingsCoordinator: PinCodeConfirmViewModelDelegate {
  func pinCodeConfirmViewModelDidFinish(_ viewModel: PinCodeConfirmViewModel) {
    popToController(ProfileSettingsViewController.self)
  }
}

// MARK: - PinCodeConfirmViewControllerDelegate
extension ProfileSettingsCoordinator: PinCodeConfirmViewControllerDelegate {
  func pinCodeConfirmViewControllerDidRequestGoBack(_ viewController: PinCodeConfirmViewController) {
    popToController(ProfileSettingsViewController.self)
  }
}

// MARK: - MFMailComposeViewControllerDelegate
extension ProfileSettingsCoordinator: MFMailComposeViewControllerDelegate {
  func mailComposeController(_ controller: MFMailComposeViewController,
                             didFinishWith result: MFMailComposeResult, error: Error?) {
    switch result {
    case .failed:
      if let error = error {
        onDidFailSendEmail?(error)
      }
    default:
      break
    }
  }
}
