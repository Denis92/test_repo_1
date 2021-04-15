//
//  SelfieCoordinator.swift
//  ForwardLeasing
//

import Foundation
import SumSubstanceKYC_Liveness3D

enum LivenessError: LocalizedError {
  case initializationError
  
  var errorDescription: String? {
    return R.string.selfie.livenessErrorText()
  }
}

protocol SelfieCoordinatorDelegate: class {
  func selfieCoordinator(_ coordinator: SelfieCoordinator, didFinishWithImage image: UIImage?,
                         passportData: DocumentData,
                         application: LeasingEntity)
  func selfieCoordinator(_ coordinator: SelfieCoordinator, didFinishWithApplication application: LeasingEntity)
  func selfieCoordinatorDidRequestFinishFlow(_ coordinator: SelfieCoordinator)
}

enum SelfieCoordinatorFlow {
  case hasPassportData(application: LeasingEntity), scannedPassport(application: LeasingEntity,
                                                                    passportData: ScannedPassportData)
}

class SelfieCoordinator: ConfigurableNavigationFlowCoordinator {
  typealias Configuration = SelfieCoordinatorFlow
  // MARK: - Properties
  
  weak var delegate: SelfieCoordinatorDelegate?
  
  let appDependency: AppDependency
  let navigationObserver: NavigationObserver
  let navigationController: NavigationController
  var childCoordinators: [BaseCoordinator] = []
  var onDidFinish: (() -> Void)?
  
  private var onDidReceiveError: ((Error) -> Void)?
  private let configuration: Configuration
  
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
    showSelfieScreen(animated: animated)
  }
  
  private func showSelfieScreen(animated: Bool) {
    let application: LeasingEntity
    switch configuration {
    case .hasPassportData(let flowApplication):
      application = flowApplication
    case .scannedPassport(let flowApplication, _):
      application = flowApplication
    }
    let viewModel = SelfieViewModel(application: application, dependencies: appDependency)
    viewModel.delegate = self
    onDidReceiveError = { [weak self] error in
      DispatchQueue.main.async {
        self?.navigationController.handle(error: error)
      }
    }
    let viewController = SelfieViewController(viewModel: viewModel)
    viewController.title = application.productInfo.productName
    viewController.delegate = self
    navigationController.pushViewController(viewController, animated: true)
  }
  
  private func showLivenessScreen(credentials: LivenessCredentials) {
    // swiftlint:disable:next uppercased_abbreviations
    let liveness = SSLiveness3D(mode: .faceLiveness, baseUrl: Constants.sumSubBaseURLString,
                                applicantId: credentials.applicantID,
                                token: credentials.token,
                                locale: Constants.sumSubLocale,
                                tokenExpirationHandler: { _ in
                                  self.onDidReceiveError?(LivenessError.initializationError)
                                }, completionHandler: { [weak self] viewController, status, _ in
                                  viewController.dismiss(animated: true)
                                  self?.handleLivenessStatus(status: status)
                                })

    let viewController = liveness.getController()
    viewController.modalPresentationStyle = .overCurrentContext
    navigationController.present(viewController, animated: true)
  }
  
  private func handleLivenessStatus(status: SSLiveness3DStatus) {
    switch status {
    case .verificationPassedSuccessfully:
      switch configuration {
      case .hasPassportData(let application):
        delegate?.selfieCoordinator(self, didFinishWithApplication: application)
      case .scannedPassport(let application, let passportData):
        delegate?.selfieCoordinator(self, didFinishWithImage: passportData.passportImage,
                                    passportData: passportData.passportData,
                                    application: application)
      }
    case .initializationFailed, .cameraPermissionDenied, .faceMismatched, .tokenIsInvalid:
      onDidReceiveError?(LivenessError.initializationError)
    default:
      break
    }
  }
}

// MARK: - SelfieViewControllerDelegate

extension SelfieCoordinator: SelfieViewControllerDelegate {
  func selfieViewControllerDidFinish(_ viewController: SelfieViewController) {
    delegate?.selfieCoordinatorDidRequestFinishFlow(self)
  }
}

// MARK: - SelfieViewModelDelegate

extension SelfieCoordinator: SelfieViewModelDelegate {
  func selfieViewModel(_ viewModel: SelfieViewModel,
                       didRequestToShowMakeSelfieScreenWithCredentials credentials: LivenessCredentials) {
    showLivenessScreen(credentials: credentials)
  }
}
