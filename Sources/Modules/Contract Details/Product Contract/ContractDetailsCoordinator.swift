//
//  ContractDetailsCoordinator.swift
//  ForwardLeasing
//

import Foundation

protocol ContractDetailsCoordinatorDelegate: class {
  func contractDetailsCoordinatorDidFinish(_ coordinator: ContractDetailsCoordinator)
  func contractDetailsCoordinator(_ coordinator: ContractDetailsCoordinator,
                                  didRequestUpdateContract contract: LeasingEntity)
}

extension ContractDetailsCoordinatorDelegate {
  func contractDetailsCoordinatorDidFinish(_ coordinator: ContractDetailsCoordinator) {}
  func contractDetailsCoordinator(_ coordinator: ContractDetailsCoordinator,
                                  didRequestUpdateContract contract: LeasingEntity) {}
}

struct ContractDetailsCoordinatorConfiguration {
  let applicationID: String
}

class ContractDetailsCoordinator: ConfigurableNavigationFlowCoordinator {
  typealias Configuration = ContractDetailsCoordinatorConfiguration
  
  // MARK: - Properties
  weak var delegate: ContractDetailsCoordinatorDelegate?
  
  let appDependency: AppDependency
  let navigationObserver: NavigationObserver
  let navigationController: NavigationController
  var childCoordinators: [BaseCoordinator] = []
  var onDidFinish: (() -> Void)?

  private var onDidRequestShowWebViewScreen: ((URL) -> Void)?
  private var onDidFinishPaymentSuccess: (() -> Void)?
  
  private let applicationID: String
  
  required init(appDependency: AppDependency,
                navigationController: NavigationController,
                navigationObserver: NavigationObserver,
                configuration: Configuration) {
    self.appDependency = appDependency
    self.navigationController = navigationController
    self.navigationObserver = navigationObserver
    self.applicationID = configuration.applicationID
  }

  func start(animated: Bool) {
    showContractDetailsScreen(animated: animated)
  }
  
  // MARK: - Navigation
  private func showContractDetailsScreen(animated: Bool) {
    let viewModel = ContractDetailsViewModel(dependencies: appDependency, applicationID: applicationID)
    onDidFinishPaymentSuccess = { [weak viewModel] in
      viewModel?.loadData()
    }
    viewModel.delegate = self
    let viewController = ContractDetailsViewController(viewModel: viewModel)
    viewController.delegate = self
    navigationController.pushViewController(viewController, animated: animated)
    navigationObserver.addObserver(self, forPopOf: viewController)
  }
  
  private func showWebViewScreen(with url: URL) {
    let controller = WebViewController(url: url, token: appDependency.tokenStorage.accessToken)
    navigationController.pushViewController(controller, animated: true)
  }
  
  private func showProductExchangeScreen(contract: LeasingEntity, exchangeModel: ModelInfo) {
    let flow = ExchangeCoordinatorFlow.start(contract, exchangeModel)
    let configuration = ExchangeCoordinatorConfiguration(flow: flow)
    show(ExchangeCoordinator.self, configuration: configuration, animated: true)
  }
  
  private func showDocumentsBottomSheet(with documents: [ContractDocument]) {
    let viewModel = DocumentsBottomSheetViewModel(items: documents)
    viewModel.delegate = self
    let controller = BottomSheetListViewController(viewModel: viewModel)
    onDidRequestShowWebViewScreen = { [weak controller] url in
      controller?.removeBottomSheetViewController(animated: true) { [weak self] in
        self?.showWebViewScreen(with: url)
      }
    }
    navigationController.addBottomSheetViewController(withDarkView: true, viewController: controller,
                                                      animated: true)
  }
  
  private func showPayment(with contract: LeasingEntity) {
    let configuration = PaymentRegistrationCoordinatorConfig(contract: contract)
    let coordinator = show(PaymentRegistrationCoordinator.self, configuration: configuration,
                           animated: true)
    coordinator.delegate = self
  }
  
  private func showProductReturnScreen(contract: LeasingEntity) {
    let configuration = ReturnCoordinatorConfiguration(contract: contract)
    show(ReturnCoordinator.self, configuration: configuration, animated: true)
  }
}

// MARK: - ContractDetailsViewControllerDelegate
extension ContractDetailsCoordinator: ContractDetailsViewControllerDelegate {
  func contractDetailsViewControllerDidRequestGoBack(_ viewController: ContractDetailsViewController) {
    delegate?.contractDetailsCoordinatorDidFinish(self)
  }
  
  func contractDetailsViewControllerDidFinish(_ viewController: ContractDetailsViewController) {
    delegate?.contractDetailsCoordinatorDidFinish(self)
  }
}

// MARK: - ContractDetailsViewModelDelegate
extension ContractDetailsCoordinator: ContractDetailsViewModelDelegate {
  func contractDetailsViewModel(_ viewModel: ContractDetailsViewModel,
                                didRequestShowPDFDocuments pdfDocuments: [ContractDocument]) {
    showDocumentsBottomSheet(with: pdfDocuments)
  }
  
  func contractDetailsViewModel(_ viewModel: ContractDetailsViewModel, didRequestOpenURL url: URL) {
    showWebViewScreen(with: url)
  }
  
  func contractDetailsViewModel(_ viewModel: ContractDetailsViewModel, didUpdateContract contract: LeasingEntity) {
    delegate?.contractDetailsCoordinator(self, didRequestUpdateContract: contract)
  }
  
  func contractDetailsViewModel(_ viewModel: ContractDetailsViewModel,
                                didRequestToMakePaymentWith contract: LeasingEntity) {
    showPayment(with: contract)
  }

  func contractDetailsViewModel(_ viewModel: ContractDetailsViewModel,
                                didRequestToExchangeProductToModel model: ModelInfo,
                                contract: LeasingEntity) {
    showProductExchangeScreen(contract: contract, exchangeModel: model)
  }

  func contractDetailsViewModel(_ viewModel: ContractDetailsViewModel,
                                didRequestToContinueExchangeWith contract: LeasingEntity) {
    if contract.contractActionInfo?.diagnosticType == .forward,
       let sessionID = contract.contractActionInfo?.checkSessionID,
       let sessionURL = contract.contractActionInfo?.checkSessionURL {
      appDependency.diagnosticService.showDiagnosticOrContinue(with: sessionID,
                                                               sessionURL: sessionURL).cauterize()
    } else {
      let flow = ExchangeCoordinatorFlow.continue(contract)
      let configuration = ExchangeCoordinatorConfiguration(flow: flow)
      show(ExchangeCoordinator.self, configuration: configuration, animated: true)
    }
  }

  func contractDetailsViewModel(_ viewModel: ContractDetailsViewModel,
                                didRequestToReturnProductWith contract: LeasingEntity) {
    showProductReturnScreen(contract: contract)
  }
}

// MARK: - DocumentsBottomSheetViewModelDelegate
extension ContractDetailsCoordinator: DocumentsBottomSheetViewModelDelegate {
  func documentsBottomSheetViewModel(_ viewModel: DocumentsBottomSheetViewModel,
                                     didRequestShowPDFWithURL url: URL) {
    onDidRequestShowWebViewScreen?(url)
  }
}

// MARK: - PaymentRegistrationCoordintorDelegate
extension ContractDetailsCoordinator: PaymentRegistrationCoordinatorDelegate {
  func paymentRegistrationCoordinatorDidFinishSuccess(_ coordinator: PaymentRegistrationCoordinator) {
    onDidFinishPaymentSuccess?()
  }
}
