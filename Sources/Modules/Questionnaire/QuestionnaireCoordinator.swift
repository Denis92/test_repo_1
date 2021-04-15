//
//  QuestionnaireCoordinator.swift
//  ForwardLeasing
//

import UIKit

protocol QuestionnaireCoordinatorDelegate: class {
  func questionnaireCoordinator(_ coordinator: QuestionnaireCoordinator,
                                didCreateBasketWith basketID: String,
                                for productDetails: ProductDetails)
  func questionnaireCoordinator(_ coordinator: QuestionnaireCoordinator,
                                didRequestReturn contract: LeasingEntity)
}
extension QuestionnaireCoordinatorDelegate {
  func questionnaireCoordinator(_ coordinator: QuestionnaireCoordinator,
                                didCreateBasketWith basketID: String,
                                for productDetails: ProductDetails) {}
  func questionnaireCoordinator(_ coordinator: QuestionnaireCoordinator,
                                didRequestReturn contract: LeasingEntity) {}
}

enum QuestionnaireFlow {
  case exchange(productDetails: ProductDetails)
  case `return`
}

struct QuestionnaireCoordinatorConfiguration {
  let flow: QuestionnaireFlow
  let contract: LeasingEntity
}

class QuestionnaireCoordinator: ConfigurableNavigationFlowCoordinator {
  typealias Configuration = QuestionnaireCoordinatorConfiguration
  
  // MARK: - Properties
  weak var delegate: QuestionnaireCoordinatorDelegate?
  
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
    showQuestionnaire()
  }
  
  // MARK: - Private Methods
  private func showQuestionnaire() {
    let viewModel = QuestionnaireViewModel(dependencies: appDependency,
                                           contract: configuration.contract,
                                           flow: configuration.flow)
    viewModel.delegate = self
    let controller = QuestionnaireViewController(viewModel: viewModel)
    controller.delegate = self
    navigationController.pushViewController(controller, animated: true)
    navigationObserver.addObserver(self, forPopOf: controller)
  }
  
  private func showQuestionnaireResult(with gradeInfo: QuestionGradeInfo, contract: LeasingEntity) {
    switch configuration.flow {
    case .exchange(let exchangeModel):
      showQuestionnaireExchangeResult(with: gradeInfo,
                                      contract: contract,
                                      exchangeModel: exchangeModel)
    case .return:
      showQuestionnaireReturnResult(with: gradeInfo,
                                    contract: contract)
    }
  }

  private func showQuestionnaireExchangeResult(with gradeInfo: QuestionGradeInfo,
                                               contract: LeasingEntity,
                                               exchangeModel: ProductDetails) {
    let input = QuestionnaireExchangeResultViewModelInput(contract: contract,
                                                          exchangeModel: exchangeModel,
                                                          gradeInfo: gradeInfo)
    let viewModel = QuestionnaireExchangeResultViewModel(dependencies: appDependency, input: input)
    viewModel.delegate = self
    let controller = QuestionnaireResultViewController(viewModel: viewModel)
    controller.delegate = self
    navigationController.pushViewController(controller, animated: true)
  }

  private func showQuestionnaireReturnResult(with gradeInfo: QuestionGradeInfo,
                                             contract: LeasingEntity) {
    let input = QuestionnaireReturnResultViewModelInput(contract: contract,
                                                        gradeInfo: gradeInfo)
    let viewModel = QuestionnaireReturnResultViewModel(dependencies: appDependency,
                                                       input: input)
    viewModel.delegate = self
    let controller = QuestionnaireResultViewController(viewModel: viewModel)
    controller.delegate = self
    navigationController.pushViewController(controller, animated: true)
  }
}

// MARK: - QuestionnaireViewModelDelegate
extension QuestionnaireCoordinator: QuestionnaireViewModelDelegate {
  func questionnaireViewModel(_ viewModel: QuestionnaireViewModel,
                              didFinishWithGrade grade: QuestionGradeInfo,
                              contract: LeasingEntity) {
    showQuestionnaireResult(with: grade, contract: contract)
  }
}

// MARK: - QuestionnaireViewControllerDelegate
extension QuestionnaireCoordinator: QuestionnaireViewControllerDelegate {
  func questionnaireViewControllerDidRequestGoBack(_ viewController: QuestionnaireViewController) {
    navigationController.popViewController(animated: true)
  }
}

// MARK: - QuestionnaireResultViewModelDelegate
extension QuestionnaireCoordinator: QuestionnaireExchangeResultViewModelDelegate {
  func questionnaireResultViewModel(_ viewModel: QuestionnaireExchangeResultViewModel,
                                    didRequestToExchangeWith basketID: String) {
    guard case let .exchange(exchangeModel) = configuration.flow else {
      return
    }
    delegate?.questionnaireCoordinator(self, didCreateBasketWith: basketID,
                                       for: exchangeModel)
  }
}

// MARK: - QuestionnaireResultViewControllerDelegate
extension QuestionnaireCoordinator: QuestionnaireResultViewControllerDelegate {
  func questionnaireResultViewControllerDidRequestGoBack(_ viewController: QuestionnaireResultViewController) {
    navigationController.popViewController(animated: true)
  }
}

extension QuestionnaireCoordinator: QuestionnaireReturnResultViewModelDelegate {
  func questionnaireResultViewModel(_ viewModel: QuestionnaireReturnResultViewModel,
                                    didRequestToReturn contract: LeasingEntity) {
    delegate?.questionnaireCoordinator(self,
                                       didRequestReturn: contract)
  }
}
