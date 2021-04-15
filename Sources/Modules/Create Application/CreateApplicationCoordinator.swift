//
//  CreateApplicationCoordinator.swift
//  ForwardLeasing
//

import UIKit

enum CreateApplicationFlow {
  case new(product: LeasingProductInfo, basketID: String)
  case `continue`(application: LeasingEntity)
  case newUpgrade(product: LeasingProductInfo, basketID: String, previousApplicationID: String)
  case continueUpgrade(applictaion: LeasingEntity)

  var isUpgradeFlow: Bool {
    switch self {
    case .newUpgrade, .continueUpgrade:
      return true
    default:
      return false
    }
  }
}

protocol CreateApplicationCoordinatorDelegate: class {
  func createApplicationCoordinatorDidRequestToPopToProfile(_ coordinator: CreateApplicationCoordinator)
  func createApplicationCoordinator(_ coordinator: CreateApplicationCoordinator, didSign contract: LeasingEntity)
}

class CreateApplicationCoordinator: NSObject, ConfigurableNavigationFlowCoordinator {
  typealias Configuration = CreateApplicationFlow
  // MARK: - Properties

  let appDependency: AppDependency
  let navigationObserver: NavigationObserver
  let navigationController: NavigationController
  var childCoordinators: [BaseCoordinator] = []
  var onDidFinish: (() -> Void)?

  weak var delegate: CreateApplicationCoordinatorDelegate?

  private let utility: CreateApplicationCoordinatorUtility
  private let flow: CreateApplicationFlow
  private var leasingEntity: LeasingEntity?
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
    navigationObserver.pauseRecognizingPopGesture()
    let topViewController = navigationController.topViewController
    onNeedsToPopToStart = { [weak self, weak topViewController] in
      guard let navigationController = self?.navigationController, let viewController = topViewController else {
        return
      }
      navigationController.presentedViewController?.dismiss(animated: false, completion: nil)
      navigationController.popToViewController(viewController, animated: true)
    }
    if utility.needsToShowOnboarding {
      showOnboarding(animated: animated)
    } else {
      startApplicationFlow(animated: animated)
    }
  }

  private func startApplicationFlow(animated: Bool) {
    switch flow {
    case .new, .newUpgrade:
      showPhoneConfirmationScreen(animated: true)
    case .continue(let application):
      continueLeasingEntityFlow(leasingEntity: application, animated: animated)
    case .continueUpgrade(let application):
      continueLeasingEntityFlow(leasingEntity: application, animated: animated)
    }
  }

  private func continueLeasingEntityFlow(leasingEntity: LeasingEntity, animated: Bool) {
    self.leasingEntity = leasingEntity
    // TODO: remove self as delegate when application flow is finished
    appDependency.tokenRefreshDelegate = self
    if leasingEntity.entityType == .application {
      continueApplication(application: leasingEntity)
    } else {
      continueContract(contract: leasingEntity)
    }
  }

  private func continueApplication(application: LeasingEntity) {
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

  private func continueContract(contract: LeasingEntity) {
    let deliveringStatuses: [LeasingEntityStatus] = [.deliveryStarted, .deliveryCreated, .deliveryShipped, .deliveryCompleted]
    switch contract.status {
    case .contractInit, .contractCreated, .signSmsSend:
      showContractSigningScreen(with: contract)
    case .signed where contract.deliveryType == nil,
         .signed where contract.deliveryType == .pickup && contract.contractActionInfo?.storePoint == nil,
         .signed where contract.deliveryType == .delivery || contract.deliveryType == .deliveryPartner:
      showDeliveryProduct(with: contract)
    case let status where deliveringStatuses.contains(status):
      showSignedContractScreen(application: contract,
                               storePointInfo: contract.contractActionInfo?.storePoint)
    case .signed where contract.deliveryType == .pickup && contract.contractActionInfo?.storePoint != nil, .actSigned:
      showSignedContractScreen(application: contract,
                               storePointInfo: contract.contractActionInfo?.storePoint)
    default:
      break
    }
  }

  private func showOnboarding(animated: Bool) {
    let configuration = OnboardingCoordinatorConfiguration(type: .order)
    let coordinator = show(OnboardingCoordinator.self, configuration: configuration, animated: animated)
    coordinator.delegate = self
    utility.markOnboardingAsShown()
  }

  private func showPhoneConfirmationScreen(animated: Bool) {
    let info: ApplicationCreationInfo
    let configuration: PersonalDataRegistrationFlow
    switch flow {
    case .new(let product, let basketID):
      info = ApplicationCreationInfo(basketID: basketID,
                                     previousApplicationID: nil,
                                     product: product)
    case .continue, .continueUpgrade:
      return
      // should not show this screen for continuing application creation
    case .newUpgrade(let product, let basketID, let previousApplicationID):
      info = ApplicationCreationInfo(basketID: basketID,
                                     previousApplicationID: previousApplicationID,
                                     product: product)
    }

    configuration = .createApplication(info: info)
    let coordintator = show(PersonalDataRegistrationCoordinator.self, configuration: configuration, animated: true)
    coordintator.delegate = self
  }

  private func showOTPConfirmationScreen(application: LeasingEntity) {
    let coordintator = show(PersonalDataRegistrationCoordinator.self, configuration: .showOTP(application: application),
                            animated: true)
    coordintator.delegate = self
  }

  private func showUploadPassportScreen(application: LeasingEntity) {
    let config = PassportScanCoordinatorConfiguration(application: application)
    let coordintator = show(PassportScanCoordinator.self, configuration: config,
                            animated: true)
    coordintator.delegate = self
  }

  private func showSelfieScreen(flow: SelfieCoordinatorFlow) {
    let coordintator = show(SelfieCoordinator.self, configuration: flow,
                            animated: true)
    coordintator.delegate = self
  }

  private func showCheckPhotosScreen(flow: CheckPhotosCoordinatorFlow) {
    let coordintator = show(CheckPhotosCoordinator.self, configuration: flow, animated: true)
    coordintator.delegate = self
  }

  private func showPassportConfirmation(application: LeasingEntity, passportData: DocumentData?, passportImage: UIImage?,
                                        animated: Bool) {
    let configuration = PassportDataConfirmationConfiguration(application: application,
                                                              passportData: passportData,
                                                              passportImage: passportImage)
    let coordinator = show(PassportDataConfirmationCoordinator.self, configuration: configuration, animated: animated)
    coordinator.delegate = self
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
                                                                    isUpgrade: self.flow.isUpgradeFlow)
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

  private func showSendingApplication(with application: LeasingEntity) {
    let configuration = SendingApplicationCoordinatorConfig(application: application)
    let coordinator = show(SendingApplicationCoordinator.self, configuration: configuration, animated: true)
    coordinator.delegate = self
  }

  private func showContractSigningScreen(with application: LeasingEntity) {
    let configuration = ContractSigningCoordinatorConfiguration(application: application)
    let coordinator = show(ContractSigningCoordinator.self, configuration: configuration, animated: true)
    coordinator.delegate = self
  }
  
  private func showDeliveryProduct(with application: LeasingEntity) {
    let configuration = DeliveryProductCoordinatorConfiguration(leasingEntity: application)
    let coordinator = show(DeliveryProductCoordinator.self, configuration: configuration, animated: true)
    coordinator.delegate = self
  }

  private func showSignedContractScreen(application: LeasingEntity, storePointInfo: StorePointInfo?) {
    let config = SignedContractCoordinatorConfiguration(application: application, storePointInfo: storePointInfo)
    let coordinator = show(SignedContractCoordinator.self, configuration: config, animated: true)
    coordinator.delegate = self
  }

  private func popToCurrentApplications() {
    if let controller = navigationController.viewControllers.first(where: { $0 is CurrentApplicationsViewController }) {
      navigationController.popToViewController(controller, animated: true)
    }
  }
  
  private func popToMapViewController() {
    if let controller = navigationController.viewControllers.first(where: { $0 is MapViewController }) {
      navigationController.popToViewController(controller, animated: true)
    }
  }

  private func showRefreshLeasingEntityScreen(with leasingEntity: LeasingEntity) {
    let viewModel = LeasingEntityDataRefreshViewModel(dependencies: appDependency,
                                                      leasingEntity: leasingEntity)
    viewModel.delegate = self
    let viewController = DataRefreshViewController(viewModel: viewModel)
    navigationController.pushViewController(viewController, animated: true)
  }
}

// MARK: - OnboardingCoordinatorDelegate

extension CreateApplicationCoordinator: OnboardingCoordinatorDelegate {
  func onboardingCoordinatorDidFinish(_ coordinator: OnboardingCoordinator) {
    startApplicationFlow(animated: true)
  }
}

// MARK: - PersonalDataRegistrationCoordinatorDelegate
extension CreateApplicationCoordinator: PersonalDataRegistrationCoordinatorDelegate {
  func personalDataRegistrationCoordinator(_ coordinator: PersonalDataRegistrationCoordinator,
                                           didFinishWithApplication application: LeasingEntity) {
    continueLeasingEntityFlow(leasingEntity: application, animated: true)
  }

  func personalDataRegistrationCoordinatorDidEncounterCriticalError(_ coordinator: PersonalDataRegistrationCoordinator) {
    onNeedsToPopToStart?()
  }
  
  func personalDataRegistrationCoordinatorDidRequestToFinishFlow(_ coordinator: PersonalDataRegistrationCoordinator) {
    onNeedsToPopToStart?()
  }

  func personalDataRegistrationCoordinatorDidRequestToPopToProfile(_ coordinator: PersonalDataRegistrationCoordinator) {
    navigationController.presentedViewController?.dismiss(animated: false, completion: nil)
    delegate?.createApplicationCoordinatorDidRequestToPopToProfile(self)
  }

  func personalDataRegistrationCoordinator(_ coordinator: PersonalDataRegistrationCoordinator,
                                           didRequestShowApplicationList applications: [LeasingEntity],
                                           applicationCreationInfo: ApplicationCreationInfo?) {
    showCurrentApplicationsList(applications: applications, applicationCreationInfo: applicationCreationInfo)
  }
}

// MARK: - CurrentApplicationsCoordinatorDelegate
extension CreateApplicationCoordinator: CurrentApplicationsCoordinatorDelegate {
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
    continueLeasingEntityFlow(leasingEntity: application, animated: true)
  }

  func currentApplicationsCoordinator(_ coordinator: CurrentApplicationsCoordinator,
                                      didRequestToContinueOTPFlowWith application: LeasingEntity) {
    showOTPConfirmationScreen(application: application)
  }

  func currentApplicationsCoordinatorDidEncounterCriticalError(_ coordinator: CurrentApplicationsCoordinator) {
    onNeedsToPopToStart?()
  }

  func currentApplicationsCoordinator(_ coordinator: CurrentApplicationsCoordinator,
                                      didRequestToFinishWith application: LeasingEntity) {
    showSendingApplication(with: application)
  }
}

// MARK: - PassportDataConfirmationCoordinatorDelegate
extension CreateApplicationCoordinator: PassportDataConfirmationCoordinatorDelegate {
  func passportDataConfirmationCoordinatorDidRequestFinishFlow(_ coordinator: PassportDataConfirmationCoordinator) {
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
    showCurrentApplicationsList(applications: applicationList, activeApplicationData: activeApplicationData)
  }
}

// MARK: - PassportScanCoordinatorDelegate
extension CreateApplicationCoordinator: PassportScanCoordinatorDelegate {
  func passportScanCoordinatorDidRequestFinishFlow(_ coordinator: PassportScanCoordinator) {
    onNeedsToPopToStart?()
  }

  func passportScanCoordinator(_ coordinator: PassportScanCoordinator, didFinishWithImage image: UIImage?,
                               passportData: DocumentData,
                               application: LeasingEntity) {
    showSelfieScreen(flow: .scannedPassport(application: application,
                                            passportData: ScannedPassportData(passportImage: image,
                                                                              passportData: passportData)))
  }
}

// MARK: - SelfieCoordinatorDelegate
extension CreateApplicationCoordinator: SelfieCoordinatorDelegate {
  func selfieCoordinatorDidRequestFinishFlow(_ coordinator: SelfieCoordinator) {
    onNeedsToPopToStart?()
  }

  func selfieCoordinator(_ coordinator: SelfieCoordinator, didFinishWithImage image: UIImage?,
                         passportData: DocumentData,
                         application: LeasingEntity) {
    showCheckPhotosScreen(flow: .scannedPassport(application: application,
                                                 passportData: ScannedPassportData(passportImage: image,
                                                                                   passportData: passportData)))
  }

  func selfieCoordinator(_ coordinator: SelfieCoordinator, didFinishWithApplication application: LeasingEntity) {
    showCheckPhotosScreen(flow: .hasPassportData(application: application))
  }
}

// MARK: - CheckPhotosCoordinatorDelegate
extension CreateApplicationCoordinator: CheckPhotosCoordinatorDelegate {
  func checkPhotosCoordinator(_ coordinator: CheckPhotosCoordinator, didFinishWithImage image: UIImage?,
                              passportData: DocumentData,
                              application: LeasingEntity) {
    showPassportConfirmation(application: application, passportData: passportData, passportImage: image, animated: true)
  }

  func checkPhotosCoordinator(_ coordinator: CheckPhotosCoordinator, didRequestMakeSelfieWithImage image: UIImage?,
                              passportData: DocumentData,
                              application: LeasingEntity) {
    showSelfieScreen(flow: .scannedPassport(application: application,
                                            passportData: ScannedPassportData(passportImage: image,
                                                                              passportData: passportData)))
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

// MARK: - IdentityConfirmationCheckViewModelDelegate
extension CreateApplicationCoordinator: IdentityConfirmationCheckViewModelDelegate {
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
extension CreateApplicationCoordinator: IdentityConfirmationCheckViewControllerDelegate {
  func identityConfirmationCheckViewControllerDidRequestGoBack(_ controller: IdentityConfirmationCheckViewController) {
    onNeedsToPopToStart?()
  }
}

// MARK: - TokenRefreshDelegate
extension CreateApplicationCoordinator: TokenRefreshDelegate {
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

// MARK: - UIAdaptivePresentationControllerDelegate
extension CreateApplicationCoordinator: UIAdaptivePresentationControllerDelegate {
  func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
    onDidDismissModalController?()
  }
}

// MARK: - ContractSigningCoordinator
extension CreateApplicationCoordinator: ContractSigningCoordinatorDelegate {
  func contractSigningCoordinatorDidSignContract(_ coordinator: ContractSigningCoordinator,
                                                 with application: LeasingEntity) {
    showRefreshLeasingEntityScreen(with: application)
  }

  func contractSigningCoordinatorDidFinish(_ coordinator: ContractSigningCoordinator) {
    onNeedsToPopToStart?()
  }
}

// MARK: - SendingApplicationCoordinatorDelegate
extension CreateApplicationCoordinator: SendingApplicationCoordinatorDelegate {
  func sendingApplicationCoordinator(_ coordinator: SendingApplicationCoordinator,
                                     didFinishWithApplication application: LeasingEntity) {
    showContractSigningScreen(with: application)
  }

  func sendingApplicationCoordinatorDidRequestCheckLater(_ coordinator: SendingApplicationCoordinator) {
    delegate?.createApplicationCoordinatorDidRequestToPopToProfile(self)
  }

  func sendingApplicationCoordinatorDidCancel(_ coordinator: SendingApplicationCoordinator) {
    delegate?.createApplicationCoordinatorDidRequestToPopToProfile(self)
  }

  func sendingApplicationCoordinatorDidRequestClose(_ coordinator: SendingApplicationCoordinator) {
    onNeedsToPopToStart?()
  }
}

// MARK: - DeliveryProductCoordinatorDelegate
extension CreateApplicationCoordinator: DeliveryProductCoordinatorDelegate {
  func deliveryProductCoordinator(_ coordinator: DeliveryProductCoordinator,
                                  didFinishWithDeliveryWithLeasingEntity leasingEntity: LeasingEntity) {
    showSignedContractScreen(application: leasingEntity, storePointInfo: nil)
  }
  
  func deliveryProductCoordinatorDidRequestReturnToProfile(_ coordinator: DeliveryProductCoordinator) {
    delegate?.createApplicationCoordinatorDidRequestToPopToProfile(self)
  }
  
  func deliveryProductCoordinator(_ coordinator: DeliveryProductCoordinator,
                                  didFinishWithStorePointInfo storePoint: StorePointInfo,
                                  application: LeasingEntity) {
    showSignedContractScreen(application: application, storePointInfo: storePoint)
  }

  func deliveryProductCoordinatorDidCancelDelivery(_ coordinator: DeliveryProductCoordinator) {
    delegate?.createApplicationCoordinatorDidRequestToPopToProfile(self)
  }
  
  func deliveryProductCoordinatorDidRequestToFinishFlow(_ coordinator: DeliveryProductCoordinator) {
    onNeedsToPopToStart?()
  }
}

// MARK: - SignedContractCoordinatorDelegate

extension CreateApplicationCoordinator: SignedContractCoordinatorDelegate {
  func signedContractCoordinatorDidRequestToClose(_ coordinator: SignedContractCoordinator) {
    onNeedsToPopToStart?()
  }
  
  func signedContractCoordinator(_ coordinator: SignedContractCoordinator,
                                 didRequestToSelectOtherStoreWith application: LeasingEntity) {
    popToMapViewController()
  }
  
  func signedContractCoordinator(_ coordinator: SignedContractCoordinator,
                                 didFinishWithContract contract: LeasingEntity) {
    delegate?.createApplicationCoordinatorDidRequestToPopToProfile(self)
  }
}

// MARK: - LeasingEntityDataRefreshViewModelDelegate

extension CreateApplicationCoordinator: LeasingEntityDataRefreshViewModelDelegate {
  func leasingEntityDataRefreshViewModel(_ viewModel: LeasingEntityDataRefreshViewModel, didRefresh leasingEntity: LeasingEntity) {
    // TODO: - may be use application.previousApplicationId
    switch leasingEntity.type {
    case .new:
      showDeliveryProduct(with: leasingEntity)
    case .upgrade:
      delegate?.createApplicationCoordinator(self, didSign: leasingEntity)
    }
  }

  func leasingEntityDataRefreshViewModelDidFail(_ viewModel: LeasingEntityDataRefreshViewModel) {
    onNeedsToPopToStart?()
  }

}
