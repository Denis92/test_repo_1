//
//  QuestionnaireResultViewModel.swift
//  ForwardLeasing
//

import UIKit
import PromiseKit

struct QuestionnaireExchangeResultViewModelInput {
  let contract: LeasingEntity
  let exchangeModel: ProductDetails
  let gradeInfo: QuestionGradeInfo
}

protocol QuestionnaireExchangeResultViewModelDelegate: class {
  func questionnaireResultViewModel(_ viewModel: QuestionnaireExchangeResultViewModel,
                                    didRequestToExchangeWith basketID: String)
}

class QuestionnaireExchangeResultViewModel: QuestionnaireResultViewModelProtocol {
  // MARK: - Types
  typealias Dependencies = HasBasketService & HasUserDataStore

  // MARK: - Properties
  var onDidRequestToShowErrorBanner: ((Error) -> Void)?
  var onDidStartRequest: (() -> Void)?
  var onDidFinishRequest: (() -> Void)?

  weak var delegate: QuestionnaireExchangeResultViewModelDelegate?
  
  var screenTitle: String {
    return R.string.exchangeInfo.screenTitle()
  }

  let questionnaireFormatter: QuestionnaireFormatter
  private(set) lazy var starsViewModel = makeStarsViewModel()
  private(set) lazy var priceListViewModel = makePriceListViewModel()
  private let dependencies: Dependencies
  private let input: QuestionnaireExchangeResultViewModelInput
  private let priceFormatter = FullExhangePriceFormatter()
  private let viewModelsFactory = QuestionnaireResultViewModelsFactory()

  // MARK: - Init
  init(dependencies: Dependencies,
       input: QuestionnaireExchangeResultViewModelInput) {
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
      dependencies.basketService.createBasket(productCode: input.exchangeModel.code,
                                              deliveryType: .pickup,
                                              userID: dependencies.userDataStore.userID)
    }.ensure {
      self.onDidFinishRequest?()
    }.done { response in
      self.delegate?.questionnaireResultViewModel(self,
                                                  didRequestToExchangeWith: response.basketID)
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
                                                    earlyPriceDescription: R.string.exchangeInfo.earlyExchangePriceTitle())
  }
}
