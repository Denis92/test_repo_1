//
//  CheckPhotosCoordinator.swift
//  ForwardLeasing
//

import UIKit

protocol CheckPhotosCoordinatorDelegate: class {
  func checkPhotosCoordinator(_ coordinator: CheckPhotosCoordinator, didFinishWithImage image: UIImage?,
                              passportData: DocumentData,
                              application: LeasingEntity)
  func checkPhotosCoordinator(_ coordinator: CheckPhotosCoordinator, didRequestMakeSelfieWithImage image: UIImage?,
                              passportData: DocumentData,
                              application: LeasingEntity)
  func checkPhotosCoordinator(_ coordinator: CheckPhotosCoordinator,
                              didRequestMakeSelfieWithApplication application: LeasingEntity)
  func checkPhotosCoordinator(_ coordinator: CheckPhotosCoordinator,
                              didFinishWithApplication application: LeasingEntity)
}

enum CheckPhotosCoordinatorFlow {
  case hasPassportData(application: LeasingEntity), scannedPassport(application: LeasingEntity,
                                                                         passportData: ScannedPassportData)
}

class CheckPhotosCoordinator: ConfigurableNavigationFlowCoordinator {
  typealias Configuration = CheckPhotosCoordinatorFlow
  // MARK: - Properties
  
  weak var delegate: CheckPhotosCoordinatorDelegate?
  
  let appDependency: AppDependency
  let navigationObserver: NavigationObserver
  let navigationController: NavigationController
  var childCoordinators: [BaseCoordinator] = []
  var onDidFinish: (() -> Void)?
  
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
  
  // MARK: - Public Methods
  
  func start(animated: Bool) {
    showCheckPhotos(animated: animated)
  }
  
  // MARK: - Private Methods
  private func showCheckPhotos(animated: Bool) {
    let application: LeasingEntity
    switch configuration {
    case .hasPassportData(let flowApplication):
      application = flowApplication
    case .scannedPassport(let flowApplication, _):
      application = flowApplication
    }
    let viewModel = CheckPhotosViewModel(dependency: appDependency, application: application)
    viewModel.delegate = self
    let controller = CheckPhotosViewController(viewModel: viewModel)
    navigationController.pushViewController(controller, animated: animated)
  }
}

// MARK: - CheckPhotosViewModelDelegate
extension CheckPhotosCoordinator: CheckPhotosViewModelDelegate {
  func checkPhotosViewModelDidRequestSelfie(_ viewModel: CheckPhotosViewModel) {
    switch configuration {
    case .hasPassportData(let application):
      delegate?.checkPhotosCoordinator(self, didRequestMakeSelfieWithApplication: application)
    case .scannedPassport(let application, let passportData):
      delegate?.checkPhotosCoordinator(self, didRequestMakeSelfieWithImage: passportData.passportImage,
                                       passportData: passportData.passportData,
                                       application: application)
    }
  }

  func checkPhotosViewModel(_ viewModel: CheckPhotosViewModel, didFinishSuccessfullyWithApplication
                              application: LeasingEntity) {
    switch configuration {
    case .hasPassportData:
      delegate?.checkPhotosCoordinator(self, didFinishWithApplication: application)
    case .scannedPassport(_, let passportData):
      delegate?.checkPhotosCoordinator(self, didFinishWithImage: passportData.passportImage,
                                       passportData: passportData.passportData,
                                       application: application)
    }
  }
}
