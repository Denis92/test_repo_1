//
//  PassportDataConfirmationCoordinator.swift
//  ForwardLeasing
//

import UIKit

protocol PassportDataConfirmationCoordinatorDelegate: class {
  func passportDataConfirmationCoordinator(_ coordinator: PassportDataConfirmationCoordinator,
                                           didFinishWithApplication application: LeasingEntity)
  func passportDataConfirmationCoordinator(_ coordinator: PassportDataConfirmationCoordinator,
                                           didRequestSelectApplicationFromList applicationList: [LeasingEntity],
                                           activeApplicationData: (LeasingEntity, ClientPersonalData)?)
  func passportDataConfirmationCoordinator(_ coordinator: PassportDataConfirmationCoordinator,
                                           didRequestRescanPassportForApplication application: LeasingEntity)
  func passportDataConfirmationCoordinatorDidRequestFinishFlow(_ coordinator: PassportDataConfirmationCoordinator)
}

struct PassportDataConfirmationConfiguration {
  let application: LeasingEntity
  let passportData: DocumentData?
  let passportImage: UIImage?
}

class PassportDataConfirmationCoordinator: ConfigurableNavigationFlowCoordinator {
  // MARK: - Types
  typealias Configuration = PassportDataConfirmationConfiguration
  
  // MARK: - Properties
  var navigationObserver: NavigationObserver
  weak var delegate: PassportDataConfirmationCoordinatorDelegate?
  var navigationController: NavigationController
  var childCoordinators: [BaseCoordinator] = []
  var onDidFinish: (() -> Void)?
  var appDependency: AppDependency

  private let application: LeasingEntity
  private let passportData: DocumentData?
  private let passportImage: UIImage?

  // MARK: - Init
  required init(appDependency: AppDependency,
                navigationController: NavigationController,
                navigationObserver: NavigationObserver,
                configuration: Configuration) {
    self.navigationController = navigationController
    self.navigationObserver = navigationObserver
    self.appDependency = appDependency
    self.application = configuration.application
    self.passportData = configuration.passportData
    self.passportImage = configuration.passportImage
  }

  // MARK: - Init
  func start(animated: Bool) {
    if application.previousApplicationID == nil {
      showEditIdentityConfirmation()
    } else {
      showCheckIdentityConfirmation()
    }
  }

  private func showEditIdentityConfirmation() {
    let input = IdentityConfirmationEditViewModelInput(application: application, passportData: passportData, passportImage: passportImage)
    let viewModel = IdentityConfirmationEditViewModel(input: input,
                                                      dependencies: appDependency)
    viewModel.delegate = self
    let controller = IdentityConfirmationEditViewController(viewModel: viewModel)
    controller.delegate = self
    navigationController.pushViewController(controller, animated: true)
    navigationObserver.addObserver(self, forPopOf: navigationController)
  }

  private func showCheckIdentityConfirmation() {
    let viewModel = IdentityConfirmationCheckViewModel(dependencies: appDependency, application: application)
    viewModel.delegate = self
    let controller = IdentityConfirmationCheckViewController(viewModel: viewModel)
    controller.delegate = self
    navigationController.pushViewController(controller, animated: true)
  }
}

// MARK: - IdentityConfirmationEditViewControllerDelegate

extension PassportDataConfirmationCoordinator: IdentityConfirmationEditViewControllerDelegate {
  func identityConfirmationEditViewControllerDidRequestGoBack(_ viewController: IdentityConfirmationEditViewController) {
    delegate?.passportDataConfirmationCoordinatorDidRequestFinishFlow(self)
  }
  
  func identityConfirmationEditViewControllerDidRequestRescanPassport(_ viewController: IdentityConfirmationEditViewController) {
    delegate?.passportDataConfirmationCoordinator(self, didRequestRescanPassportForApplication: application)
  }
}

// MARK: - IdentityConfirmationEditViewModelDelegate

extension PassportDataConfirmationCoordinator: IdentityConfirmationEditViewModelDelegate {
  func identityConfirmationEditViewModel(_ viewModel: IdentityConfirmationEditViewModel,
                                         didFinishWithApplication application: LeasingEntity) {
    delegate?.passportDataConfirmationCoordinator(self, didFinishWithApplication: application)
  }

  func identityConfirmationEditViewModel(_ viewModel: IdentityConfirmationEditViewModel,
                                         didRequestSelectApplicationFromList applicationList: [LeasingEntity],
                                         activeApplicationData: (LeasingEntity, ClientPersonalData)?) {
    delegate?.passportDataConfirmationCoordinator(self, didRequestSelectApplicationFromList: applicationList,
                                                  activeApplicationData: activeApplicationData)
  }
  
  func identityConfirmationEditViewModelDidRequestToForceFinish(_ viewModel: IdentityConfirmationEditViewModel) {
    delegate?.passportDataConfirmationCoordinatorDidRequestFinishFlow(self)
  }
}

extension PassportDataConfirmationCoordinator: IdentityConfirmationCheckViewControllerDelegate {
  func identityConfirmationCheckViewControllerDidRequestGoBack(_ controller: IdentityConfirmationCheckViewController) {
    delegate?.passportDataConfirmationCoordinatorDidRequestFinishFlow(self)
  }
}

extension PassportDataConfirmationCoordinator: IdentityConfirmationCheckViewModelDelegate {
  func identityConfirmationCheckViewModel(_ viewModel: IdentityConfirmationCheckViewModel,
                                          didRequestSelectApplicationFromList applicationList: [LeasingEntity],
                                          activeApplicationData: (LeasingEntity, ClientPersonalData)?) {
    delegate?.passportDataConfirmationCoordinator(self, didRequestSelectApplicationFromList: applicationList,
                                                  activeApplicationData: activeApplicationData)
  }

  func identityConfirmationCheckViewModel(_ viewModel: IdentityConfirmationCheckViewModel,
                                          didRequestRepeatScanWithApplication application: LeasingEntity) {
    delegate?.passportDataConfirmationCoordinator(self, didRequestRescanPassportForApplication: application)
  }

  func identityConfirmationCheckViewModel(_ viewModel: IdentityConfirmationCheckViewModel,
                                          didFinishWithApplication application: LeasingEntity) {
    delegate?.passportDataConfirmationCoordinator(self, didFinishWithApplication: application)
  }

}
