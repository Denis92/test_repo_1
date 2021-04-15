//
//  CreateApplicationCoordinator.swift
//  ForwardLeasing
//

import UIKit

// TODO: - Delete file if no time for refatoring

enum CreateApplicationFlowNEW {
  case new(product: LeasingProductInfo, basketID: String, previousApplicationID: String?)
  case `continue`(application: LeasingEntity)
}

protocol CreateApplicationCoordinatorNEWDelegate: class {
  func createApplicationCoordinatorNEWDidRequestPopToStart(_ coordinator: CreateApplicationCoordinatorNEW)
  func createApplicationCoordinatorNEWDidRequestReset(_ coordinator: CreateApplicationCoordinatorNEW)
  func createApplicationCoordinatorNEW(_ coordinator: CreateApplicationCoordinatorNEW,
                                       didRequestSign leasingEntity: LeasingEntity)
}

class CreateApplicationCoordinatorNEW: NSObject, ConfigurableNavigationFlowCoordinator {
  typealias Configuration = CreateApplicationFlowNEW
  // MARK: - Properties

  let appDependency: AppDependency
  let navigationObserver: NavigationObserver
  let navigationController: NavigationController
  var childCoordinators: [BaseCoordinator] = []
  var onDidFinish: (() -> Void)?

  weak var delegate: CreateApplicationCoordinatorNEWDelegate?

  private let utility: CreateApplicationCoordinatorUtility
  private let flow: CreateApplicationFlowNEW
  private var leasingEntity: LeasingEntity?
  // TODO: - Remove if needeed
  private var onNeedsToPopToStart: (() -> Void)?
  private var onDidDismissModalController: (() -> Void)?

  // MARK: - Init

  required init(appDependency: AppDependency,
                navigationController: NavigationController,
                navigationObserver: NavigationObserver,
                configuration: Configuration) {
    self.navigationController = navigationController
    self.navigationObserver = navigationObserver
    self.appDependency = appDependency
    self.flow = configuration
    self.utility = CreateApplicationCoordinatorUtility(dependencies: appDependency)
  }

  deinit {
    navigationObserver.resumeRecognizingPopGesture()
  }

  // MARK: - Navigation

  func start(animated: Bool) {
    switch flow {
    case .new(let product, let basketID, let previousApplicationID):
      showPhoneConfirmationScreen(product: product, basketID: basketID, previousApplicationID: previousApplicationID)
    case .continue(let application):
      continueApplication(application: application)
    }
  }

  private func showPhoneConfirmationScreen(product: LeasingProductInfo, basketID: String, previousApplicationID: String?) {
    let info = ApplicationCreationInfo(basketID: basketID, previousApplicationID: previousApplicationID, product: product)
    let configuration = PersonalDataRegistrationFlow.createApplication(info: info)

    let coordintator = show(PersonalDataRegistrationCoordinator.self, configuration: configuration, animated: true)
    coordintator.delegate = self
  }

  private func continueApplication(application: LeasingEntity) {
    self.leasingEntity = application
    // TODO: remove self as delegate when application flow is finished
    appDependency.tokenRefreshDelegate = self
    let startingStatuses: [LeasingEntityStatus] = [.draft, .confirmed, .dataSaved, .pending]
    switch application.status {
    case let status where startingStatuses.contains(status)
          && application.hasPersonalDataExist
          && application.previousApplicationID != nil:
      showSelfieScreen(flow: .hasPassportData(application: application))
    case let status where startingStatuses.contains(status) && !application.hasPassportImage:
      showUploadPassportScreen(application: application)
    case let status where startingStatuses.contains(status) && !application.hasSelfieImage:
      showSelfieScreen(flow: .hasPassportData(application: application))
    case let status where startingStatuses.contains(status)
          && (application.passportSelfieStatus == .notChecked || application.passportSelfieStatus == .pending):
      showCheckPhotosScreen(flow: .hasPassportData(application: application))
    case let status where startingStatuses.contains(status) && !application.hasPersonalDataExist:
      showPassportConfirmation(application: application,
                               passportData: nil,
                               passportImage: nil,
                               animated: true)
    case let status where startingStatuses.contains(status) && application.clientPersonalData != nil:
      showPassportConfirmation(application: application,
                               passportData: application.clientPersonalData?.passportData,
                               passportImage: nil,
                               animated: true)
    case .inReview:
      showSendingApplication(with: application)
    case .approved:
      showContractSigningScreen(with: application)
    default:
      break
    }
  }

  private func showSelfieScreen(flow: SelfieCoordinatorFlow) {
    let coordintator = show(SelfieCoordinator.self, configuration: flow,
                            animated: true)
    coordintator.delegate = self
  }

  private func showUploadPassportScreen(application: LeasingEntity) {
    let config = PassportScanCoordinatorConfiguration(application: application)
    let coordintator = show(PassportScanCoordinator.self, configuration: config,
                            animated: true)
    coordintator.delegate = self
  }

  private func showCheckPhotosScreen(flow: CheckPhotosCoordinatorFlow) {
    let coordintator = show(CheckPhotosCoordinator.self, configuration: flow, animated: true)
    coordintator.delegate = self
  }

  private func showPassportConfirmation(application: LeasingEntity,
                                        passportData: DocumentData?,
                                        passportImage: UIImage?,
                                        animated: Bool) {
    let configuration = PassportDataConfirmationConfiguration(application: application,
                                                              passportData: passportData,
                                                              passportImage: passportImage)
    let coordinator = show(PassportDataConfirmationCoordinator.self, configuration: configuration, animated: animated)
    coordinator.delegate = self
  }

  private func showSendingApplication(with application: LeasingEntity) {
    let configuration = SendingApplicationCoordinatorConfig(application: application)
    let coordinator = show(SendingApplicationCoordinator.self, configuration: configuration, animated: true)
    coordinator.delegate = self
  }

  private func showContractSigningScreen(with application: LeasingEntity) {
    delegate?.createApplicationCoordinatorNEW(self, didRequestSign: application)
  }

  private func showCurrentApplicationsList(applications: [LeasingEntity],
                                           applicationCreationInfo: ApplicationCreationInfo? = nil,
                                           activeApplicationData: (LeasingEntity, ClientPersonalData)? = nil) {
    let flow: CurrentApplicationsFlow
    if let info = applicationCreationInfo {
      flow = .hasNoCurrentApplication(applications: applications, applicationCreationInfo: info)
    } else if let activeApplicationData = activeApplicationData {
      flow = .updateClientData(applications: applications, activeApplicationData: activeApplicationData)
    } else {
      flow = .hasCurrentApplication(applications: applications)
    }
    let configuration = CurrentApplicationsCoordinatorConfiguration(flow: flow,
                                                                    isUpgrade: false)
    let coordinator = show(CurrentApplicationsCoordinator.self, configuration: configuration, animated: true)
    coordinator.delegate = self
  }

  private func showCheckIdentityConfirmation(with application: LeasingEntity) {
    let viewModel = IdentityConfirmationCheckViewModel(dependencies: appDependency, application: application)
    viewModel.delegate = self
    let controller = IdentityConfirmationCheckViewController(viewModel: viewModel)
    controller.delegate = self
    navigationController.pushViewController(controller, animated: true)
  }

  private func showOTPConfirmationScreen(application: LeasingEntity) {
    let coordintator = show(PersonalDataRegistrationCoordinator.self, configuration: .showOTP(application: application),
                            animated: true)
    coordintator.delegate = self
  }
}

// MARK: - PersonalDataRegistrationCoordinatorDelegate
extension CreateApplicationCoordinatorNEW: PersonalDataRegistrationCoordinatorDelegate {
  func personalDataRegistrationCoordinator(_ coordinator: PersonalDataRegistrationCoordinator,
                                           didFinishWithApplication application: LeasingEntity) {
    continueApplication(application: application)
  }

  func personalDataRegistrationCoordinatorDidEncounterCriticalError(_ coordinator: PersonalDataRegistrationCoordinator) {
    delegate?.createApplicationCoordinatorNEWDidRequestPopToStart(self)
  }

  func personalDataRegistrationCoordinatorDidRequestToFinishFlow(_ coordinator: PersonalDataRegistrationCoordinator) {
    delegate?.createApplicationCoordinatorNEWDidRequestPopToStart(self)
  }

  func personalDataRegistrationCoordinatorDidRequestToPopToProfile(_ coordinator: PersonalDataRegistrationCoordinator) {
    navigationController.presentedViewController?.dismiss(animated: false, completion: nil)
    delegate?.createApplicationCoordinatorNEWDidRequestReset(self)
  }

  func personalDataRegistrationCoordinator(_ coordinator: PersonalDataRegistrationCoordinator,
                                           didRequestShowApplicationList applications: [LeasingEntity],
                                           applicationCreationInfo: ApplicationCreationInfo?) {
    showCurrentApplicationsList(applications: applications,
                                applicationCreationInfo: applicationCreationInfo)
  }
}

// MARK: - TokenRefreshDelegate
extension CreateApplicationCoordinatorNEW: TokenRefreshDelegate {
  func networkServiceNeedsTokenRefresh(_ networkService: NetworkService) -> SessionRefreshing? {
    guard let application = leasingEntity else {
      return nil
    }
    let navigationController = NavigationController()
    let navigationObserver = NavigationObserver(navigationController: navigationController)
    let coordinator = PersonalDataRegistrationCoordinator(appDependency: appDependency,
                                                          navigationController: navigationController,
                                                          navigationObserver: navigationObserver,
                                                          configuration: .refreshToken(application: application))
    coordinator.delegate = self
    add(child: coordinator)
    let sessionRefresher = coordinator.showTokenRefresh(with: application)
    onDidDismissModalController = { [weak coordinator, unowned appDependency, weak self] in
      navigationController.viewControllers = []
      coordinator?.finishTokenRefreshIfNeeded()
      coordinator?.onDidFinish?()
      if !appDependency.userDataStore.isLoggedIn {
        navigationController.showErrorBanner(error: TokenRefreshError.cancelled)
        self?.onNeedsToPopToStart?()
      }
    }
    self.navigationController.presentedViewController?.dismiss(animated: false, completion: nil)
    self.navigationController.present(navigationController, animated: true, completion: nil)
    navigationController.presentationController?.delegate = self
    return sessionRefresher
  }
}

// MARK: - SelfieCoordinatorDelegate
extension CreateApplicationCoordinatorNEW: SelfieCoordinatorDelegate {
  func selfieCoordinatorDidRequestFinishFlow(_ coordinator: SelfieCoordinator) {
    delegate?.createApplicationCoordinatorNEWDidRequestPopToStart(self)
  }

  func selfieCoordinator(_ coordinator: SelfieCoordinator, didFinishWithImage image: UIImage?,
                         passportData: DocumentData,
                         application: LeasingEntity) {
    showCheckPhotosScreen(flow: .scannedPassport(application: application,
                                                 passportData: ScannedPassportData(passportImage: image,
                                                                                   passportData: passportData)))
  }

  func selfieCoordinator(_ coordinator: SelfieCoordinator,
                         didFinishWithApplication application: LeasingEntity) {
    showCheckPhotosScreen(flow: .hasPassportData(application: application))
  }
}

// MARK: - PassportScanCoordinatorDelegate
extension CreateApplicationCoordinatorNEW: PassportScanCoordinatorDelegate {
  func passportScanCoordinatorDidRequestFinishFlow(_ coordinator: PassportScanCoordinator) {
    delegate?.createApplicationCoordinatorNEWDidRequestPopToStart(self)
  }

  func passportScanCoordinator(_ coordinator: PassportScanCoordinator, didFinishWithImage image: UIImage?,
                               passportData: DocumentData,
                               application: LeasingEntity) {
    let scannedPassportData = ScannedPassportData(passportImage: image,
                                                  passportData: passportData)
    showSelfieScreen(flow: .scannedPassport(application: application,
                                            passportData: scannedPassportData))
  }
}

// MARK: - CheckPhotosCoordinatorDelegate
extension CreateApplicationCoordinatorNEW: CheckPhotosCoordinatorDelegate {
  func checkPhotosCoordinator(_ coordinator: CheckPhotosCoordinator, didFinishWithImage image: UIImage?,
                              passportData: DocumentData,
                              application: LeasingEntity) {
    showPassportConfirmation(application: application, passportData: passportData, passportImage: image, animated: true)
  }

  func checkPhotosCoordinator(_ coordinator: CheckPhotosCoordinator, didRequestMakeSelfieWithImage image: UIImage?,
                              passportData: DocumentData,
                              application: LeasingEntity) {
    let scannedPassportData = ScannedPassportData(passportImage: image,
                                                  passportData: passportData)
    showSelfieScreen(flow: .scannedPassport(application: application,
                                            passportData: scannedPassportData))
  }

  func checkPhotosCoordinator(_ coordinator: CheckPhotosCoordinator,
                              didRequestMakeSelfieWithApplication application: LeasingEntity) {
    showSelfieScreen(flow: .hasPassportData(application: application))
  }

  func checkPhotosCoordinator(_ coordinator: CheckPhotosCoordinator,
                              didFinishWithApplication application: LeasingEntity) {
    showPassportConfirmation(application: application,
                             passportData: application.clientPersonalData?.passportData,
                             passportImage: nil,
                             animated: true)
  }
}

// MARK: - PassportDataConfirmationCoordinatorDelegate
extension CreateApplicationCoordinatorNEW: PassportDataConfirmationCoordinatorDelegate {
  func passportDataConfirmationCoordinatorDidRequestFinishFlow(_ coordinator: PassportDataConfirmationCoordinator) {
    delegate?.createApplicationCoordinatorNEWDidRequestPopToStart(self)
    onNeedsToPopToStart?()
  }

  func passportDataConfirmationCoordinator(_ coordinator: PassportDataConfirmationCoordinator,
                                           didRequestRescanPassportForApplication application: LeasingEntity) {
    showUploadPassportScreen(application: application)
  }

  func passportDataConfirmationCoordinator(_ coordinator: PassportDataConfirmationCoordinator,
                                           didFinishWithApplication application: LeasingEntity) {
    showSendingApplication(with: application)
  }

  func passportDataConfirmationCoordinator(_ coordinator: PassportDataConfirmationCoordinator,
                                           didRequestSelectApplicationFromList applicationList: [LeasingEntity],
                                           activeApplicationData: (LeasingEntity, ClientPersonalData)?) {
    showCurrentApplicationsList(applications: applicationList,
                                activeApplicationData: activeApplicationData)
  }
}

// MARK: - SendingApplicationCoordinatorDelegate
extension CreateApplicationCoordinatorNEW: SendingApplicationCoordinatorDelegate {
  func sendingApplicationCoordinator(_ coordinator: SendingApplicationCoordinator,
                                     didFinishWithApplication application: LeasingEntity) {
    showContractSigningScreen(with: application)
  }

  func sendingApplicationCoordinatorDidRequestCheckLater(_ coordinator: SendingApplicationCoordinator) {
    delegate?.createApplicationCoordinatorNEWDidRequestReset(self)
  }

  func sendingApplicationCoordinatorDidCancel(_ coordinator: SendingApplicationCoordinator) {
    delegate?.createApplicationCoordinatorNEWDidRequestReset(self)
  }

  func sendingApplicationCoordinatorDidRequestClose(_ coordinator: SendingApplicationCoordinator) {
    delegate?.createApplicationCoordinatorNEWDidRequestPopToStart(self)
  }
}

// MARK: - CurrentApplicationsCoordinatorDelegate
extension CreateApplicationCoordinatorNEW: CurrentApplicationsCoordinatorDelegate {
  func currentApplicationCoordinator(_ coordinator: CurrentApplicationsCoordinator,
                                     didRequestToContinueWithoutRegistrationWith application: LeasingEntity) {
    if application.hasSelfieImage {
      showCheckIdentityConfirmation(with: application)
    } else {
      showSelfieScreen(flow: .hasPassportData(application: application))
    }
  }

  func currentApplicationsCoordinatorDidRequestFinishFlow(_ coordinator: CurrentApplicationsCoordinator) {
    onNeedsToPopToStart?()
  }

  func currentApplicationsCoordinator(_ coordinator: CurrentApplicationsCoordinator,
                                      didRequestToContinueWith application: LeasingEntity) {
    continueApplication(application: application)
  }

  func currentApplicationsCoordinator(_ coordinator: CurrentApplicationsCoordinator,
                                      didRequestToContinueOTPFlowWith application: LeasingEntity) {
    showOTPConfirmationScreen(application: application)
  }

  func currentApplicationsCoordinatorDidEncounterCriticalError(_ coordinator: CurrentApplicationsCoordinator) {
    delegate?.createApplicationCoordinatorNEWDidRequestPopToStart(self)
  }

  func currentApplicationsCoordinator(_ coordinator: CurrentApplicationsCoordinator,
                                      didRequestToFinishWith application: LeasingEntity) {
    showSendingApplication(with: application)
  }
}

// MARK: - IdentityConfirmationCheckViewModelDelegate
extension CreateApplicationCoordinatorNEW: IdentityConfirmationCheckViewModelDelegate {
  func identityConfirmationCheckViewModel(_ viewModel: IdentityConfirmationCheckViewModel,
                                          didRequestSelectApplicationFromList applicationList: [LeasingEntity],
                                          activeApplicationData: (LeasingEntity, ClientPersonalData)?) {

  }
  func identityConfirmationCheckViewModel(_ viewModel: IdentityConfirmationCheckViewModel,
                                          didRequestRepeatScanWithApplication application: LeasingEntity) {
    showUploadPassportScreen(application: application)
  }

  func identityConfirmationCheckViewModel(_ viewModel: IdentityConfirmationCheckViewModel,
                                          didFinishWithApplication application: LeasingEntity) {
    // TODO - add finish check
  }
}

// MARK: - IdentityConfirmationCheckViewControllerDelegate
extension CreateApplicationCoordinatorNEW: IdentityConfirmationCheckViewControllerDelegate {
  func identityConfirmationCheckViewControllerDidRequestGoBack(_ controller: IdentityConfirmationCheckViewController) {
    delegate?.createApplicationCoordinatorNEWDidRequestPopToStart(self)
  }
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension CreateApplicationCoordinatorNEW: UIAdaptivePresentationControllerDelegate {
  func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
    onDidDismissModalController?()
  }
}
