//
//  QuestionnaireResultViewModel.swift
//  ForwardLeasing
//

import UIKit
import PromiseKit

private extension Constants {
  static let maxNumberOfStars = 5
}

struct QuestionnaireReturnResultViewModelInput {
  let contract: LeasingEntity
  let gradeInfo: QuestionGradeInfo
}

protocol QuestionnaireReturnResultViewModelDelegate: class {
  func questionnaireResultViewModel(_ viewModel: QuestionnaireReturnResultViewModel, didRequestToReturn contract: LeasingEntity)
}

class QuestionnaireReturnResultViewModel: QuestionnaireResultViewModelProtocol {
  // MARK: - Types
  typealias Dependencies = HasContractService

  // MARK: - Properties
  var onDidRequestToShowErrorBanner: ((Error) -> Void)?
  var onDidStartRequest: (() -> Void)?
  var onDidFinishRequest: (() -> Void)?

  weak var delegate: QuestionnaireReturnResultViewModelDelegate?

  var screenTitle: String {
    return R.string.returnInfo.screenTitle()
  }

  let questionnaireFormatter: QuestionnaireFormatter
  private(set) lazy var starsViewModel = makeStarsViewModel()
  private(set) lazy var priceListViewModel = makePriceListViewModel()
  private let dependencies: Dependencies
  private let input: QuestionnaireReturnResultViewModelInput
  private let viewModelsFactory = QuestionnaireResultViewModelsFactory()

  // MARK: - Init
  init(dependencies: Dependencies,
       input: QuestionnaireReturnResultViewModelInput) {
    self.dependencies = dependencies
    self.input = input
    self.questionnaireFormatter = QuestionnaireFormatter(gradeInfo: input.gradeInfo,
                                                         contract: input.contract)
  }
  
  // MARK: - Public
  func finish() {
    // TODO: get selected delivery type
    onDidStartRequest?()
    firstly {
      dependencies.contractService.returnContract(applicationID: input.contract.applicationID).map(\.clientLeasingEntity)
    }.ensure {
      self.onDidFinishRequest?()
    }.done { contract in
      self.delegate?.questionnaireResultViewModel(self,
                                                  didRequestToReturn: contract)
    }.catch { error in
      self.onDidRequestToShowErrorBanner?(error)
    }
  }
    
  // MARK: - Private Methods
  private func makeStarsViewModel() -> StarsViewModel {
    return viewModelsFactory.makeStarsViewModel(gradeInfo: input.gradeInfo)
  }
  
  private func makePriceListViewModel() -> PriceListViewModel {
    return viewModelsFactory.makePriceListViewModel(gradeInfo: input.gradeInfo,
                                                    questionnaireFormatter: questionnaireFormatter,
                                                    earlyPriceDescription: R.string.returnInfo.earlyExchangePriceTitle())
  }
}
