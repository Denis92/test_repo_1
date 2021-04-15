//
//  PersonalDataRegistrationCoordinator.swift
//  ForwardLeasing
//

import UIKit

protocol PersonalDataRegistrationCoordinatorDelegate: class {
  func personalDataRegistrationCoordinator(_ coordinator: PersonalDataRegistrationCoordinator,
                                           didFinishWithApplication application: LeasingEntity)
  func personalDataRegistrationCoordinatorDidRequestToPopToProfile(_ coordinator: PersonalDataRegistrationCoordinator)
  func personalDataRegistrationCoordinatorDidEncounterCriticalError(_ coordinator: PersonalDataRegistrationCoordinator)
  func personalDataRegistrationCoordinatorDidRequestToFinishFlow(_ coordinator: PersonalDataRegistrationCoordinator)
  func personalDataRegistrationCoordinator(_ coordinator: PersonalDataRegistrationCoordinator,
                                           didRequestShowApplicationList applications: [LeasingEntity],
                                           applicationCreationInfo: ApplicationCreationInfo?)
}

struct ApplicationCreationInfo {
  let basketID: String
  let leasingType: LeasingApplicationType
  let previousApplicationID: String?
  let product: LeasingProductInfo?
  var phone: String?
  var email: String?

  init(basketID: String, previousApplicationID: String?, product: LeasingProductInfo?) {
    self.basketID = basketID
    self.previousApplicationID = previousApplicationID
    self.leasingType = previousApplicationID == nil
      ? LeasingApplicationType.new
      : LeasingApplicationType.upgrade
    self.product = product
  }
}

enum PersonalDataRegistrationFlow {
  case createApplication(info: ApplicationCreationInfo), showOTP(application: LeasingEntity),
       refreshToken(application: LeasingEntity)
}

class PersonalDataRegistrationCoordinator: ConfigurableNavigationFlowCoordinator {
  typealias Configuration = PersonalDataRegistrationFlow
    
  // MARK: - Properties
  
  weak var delegate: PersonalDataRegistrationCoordinatorDelegate?
  
  let appDependency: AppDependency
  let navigationObserver: NavigationObserver
  let navigationController: NavigationController
  var childCoordinators: [BaseCoordinator] = []
  var onDidFinish: (() -> Void)?
  private let configuration: Configuration
  private var rootController: UIViewController?
  private var onNeedsToFinishTokenRefresh: (() -> Void)?
  
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

  // MARK: - Public Methods
  
  func start(animated: Bool) {
    switch configuration {
    case .createApplication(let info):
      showPersonalDataRegister(info: info)
    case .showOTP(let application):
      showPhoneConfirmation(with: application)
    case .refreshToken(let application):
      showTokenRefresh(with: application)
    }
  }
  
  func finishTokenRefreshIfNeeded() {
    onNeedsToFinishTokenRefresh?()
  }
  
  @discardableResult
  func showTokenRefresh(with application: LeasingEntity) -> SessionRefreshing? {
    let viewModel = PhoneConfirmationViewModel(dependencies: appDependency,
                                               strategyType: .tokenRefresh(dependency: appDependency,
                                                                           leasingApplication: application))
    viewModel.delegate = self
    onNeedsToFinishTokenRefresh = { [weak viewModel] in
      viewModel?.finishTokenRefeshIfNeeded()
    }
    let controller = PhoneConfirmationViewController(viewModel: viewModel, hasBackButton: false)
    navigationController.pushViewController(controller, animated: false)
    return viewModel
  }
  
  // MARK: - Private Methods
  private func showPersonalDataRegister(info: ApplicationCreationInfo) {
    let viewModel = PersonalDataRegisterViewModel(dependencies: appDependency, input: info)
    viewModel.delegate = self
    let controller = RegisterViewController(viewModel: viewModel)
    rootController = controller
    controller.delegate = self
    navigationController.pushViewController(controller, animated: true)
    navigationObserver.addObserver(self, forPopOf: controller)
  }
  
  private func showPhoneConfirmation(with application: LeasingEntity) {
    let viewModel = PhoneConfirmationViewModel(dependencies: appDependency,
                                               strategyType: .leasingApplication(dependency: appDependency,
                                                                                 leasingApplication: application))
    viewModel.delegate = self
    let controller = PhoneConfirmationViewController(viewModel: viewModel)
    controller.delegate = self
    navigationController.pushViewController(controller, animated: true)
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

// MARK: - PersonalDataRegisterViewModelDelegate
extension PersonalDataRegistrationCoordinator: PersonalDataRegisterViewModelDelegate {
  func registerViewModel(_ viewModel: RegisterViewModel, didRequestOpeURL url: URL) {
    showAgreement(with: url)
  }
  
  func personalDataRegViewModel(_ viewModel: PersonalDataRegisterViewModel,
                                didRequestConfirmWithApplication application: LeasingEntity) {
    showPhoneConfirmation(with: application)
  }

  func personalDataRegViewModelDidEncounterCriticalError(_ viewModel: PersonalDataRegisterViewModel) {
    delegate?.personalDataRegistrationCoordinatorDidEncounterCriticalError(self)
  }

  func personalDataRegViewModelDidRequestPopToProfile(_ viewModel: PersonalDataRegisterViewModel) {
    delegate?.personalDataRegistrationCoordinatorDidRequestToPopToProfile(self)
  }

  func personalDataRegViewModel(_ viewModel: PersonalDataRegisterViewModel,
                                didRequestShowApplicationList applicationList: [LeasingEntity],
                                applicationCreationInfo: ApplicationCreationInfo) {
    delegate?.personalDataRegistrationCoordinator(self, didRequestShowApplicationList: applicationList,
                                                  applicationCreationInfo: applicationCreationInfo)
  }
}

// MARK: - PhoneConfirmationViewModelDelegate
extension PersonalDataRegistrationCoordinator: PhoneConfirmationViewModelDelegate {
  func phoneConfirmationViewModelDidSignIn(_ viewModel: PhoneConfirmationViewModel) {
    appDependency.authHandler?.authorize()
  }

  func phoneConfirmationViewModel(_ viewModel: PhoneConfirmationViewModel,
                                  didFinishWithApplication application: LeasingEntity) {
    delegate?.personalDataRegistrationCoordinator(self,
                                                  didFinishWithApplication: application)
  }

  func phoneConfirmationViewModel(_ viewModel: PhoneConfirmationViewModel,
                                  didRequestShowApplicationList applicationList: [LeasingEntity]) {
    delegate?.personalDataRegistrationCoordinator(self, didRequestShowApplicationList: applicationList,
                                                  applicationCreationInfo: nil)
  }
  
  func phoneConfirmationViewModel(_ viewModel: PhoneConfirmationViewModel,
                                  didFinishTokenRefreshWithCompletion completion: (() -> Void)?) {
    navigationController.dismiss(animated: true) {
      completion?()
      self.onDidFinish?()
    }
  }
  
  func phoneConfirmationViewModelDidRequestToFinishFlow(_ viewModel: PhoneConfirmationViewModel) {
    delegate?.personalDataRegistrationCoordinatorDidRequestToFinishFlow(self)
  }
}

// MARK: - PersonalDataRegisterViewControllerDelegate
extension PersonalDataRegistrationCoordinator: RegisterViewControllerDelegate {
  func registerViewControllerDidRequestGoBack(_ viewController: RegisterViewController) {
    navigationController.popViewController(animated: true)
  }
}

// MARK: - PhoneConfirmationViewControllerDelegate
extension PersonalDataRegistrationCoordinator: PhoneConfirmationViewControllerDelegate {
  func phoneConfirmationViewControllerDidRequestGoBack(_ viewController: PhoneConfirmationViewController) {
    delegate?.personalDataRegistrationCoordinatorDidRequestToFinishFlow(self)
  }
}
