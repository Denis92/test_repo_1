//
//  QuestionnaireViewModel.swift
//  ForwardLeasing
//

import UIKit
import PromiseKit

private extension Constants {
  static let yesAnswer = R.string.common.yes()
  static let hasDisadvantagesAnswer = R.string.questionnaire.hasDisadvantagesTitle()
}

protocol QuestionnaireViewModelDelegate: class {
  func questionnaireViewModel(_ viewModel: QuestionnaireViewModel, didFinishWithGrade grade: QuestionGradeInfo,
                              contract: LeasingEntity)
}

class QuestionnaireViewModel {
  // MARK: - Types
  typealias Dependencies = HasContractService & HasCatalogueService & HasApplicationService &
    HasContractService
  
  // MARK: - Properties
  var onDidReceiveError: ((Error) -> Void)?
  var onDidStartRequest: (() -> Void)?
  var onDidFinishRequest: (() -> Void)?
  var onDidUpdateViewModels: (() -> Void)?

  var title: String {
    switch flow {
    case .exchange:
      return R.string.exchangeInfo.screenTitle()
    case .return:
      return R.string.returnInfo.screenTitle()
    }
  }
  
  weak var delegate: QuestionnaireViewModelDelegate?
  
  private(set) var productInfoViewModelType: QuestionaireProductInfoViewType?
  private(set) var productQuestionnaireViewModel: ProductQuestionnaireViewModel?
  private let dependencies: Dependencies
  private var exchangeProduct: ProductDetails? {
    switch flow {
    case .exchange(let productDetails):
      return productDetails
    case .return:
      return nil
    }
  }
  private var questionnaireResponse: QuestionnaireResponse?
  private let flow: QuestionnaireFlow
  private var hasDisadvantagesQuestions: Set<Question> = []
  
  private let contract: LeasingEntity
  
  // MARK: - Init
  init(dependencies: Dependencies, contract: LeasingEntity,
       flow: QuestionnaireFlow) {
    self.dependencies = dependencies
    self.contract = contract
    self.flow = flow
  }
  
  // MARK: - Public
  func load() {
    onDidStartRequest?()
    firstly { () -> Promise<QuestionnaireResponse> in
      return self.dependencies.contractService.getQuestionnaire(applicationID: contract.applicationID)
    }.done { questionnaireResponse in
      self.questionnaireResponse = questionnaireResponse
      self.updateViewModels()
      self.onDidFinishRequest?()
    }.catch { error in
      self.onDidFinishRequest?()
      self.onDidReceiveError?(error)
    }
  }
  
  func finish() {
    guard let gradeInfo = getGradeInfo() else {
      return
    }
    delegate?.questionnaireViewModel(self, didFinishWithGrade: gradeInfo,
                                     contract: contract)
  }
  
  // MARK: - Private Methods
  private func updateViewModels() {
    productInfoViewModelType = makeProductInfoViewModel()
    productQuestionnaireViewModel = makeProductQuestionnaireViewModel()
    onDidUpdateViewModels?()
  }
  
  private func makeProductInfoViewModel() -> QuestionaireProductInfoViewType? {
    let firstItemPayment = paymentString(for: contract.productInfo.monthPay)
    let firstItem = QuestionnaireProductInfoItemViewModel(imageURL: contract.productImageURL,
                                                          productName: contract.productInfo.goodName,
                                                          payment: firstItemPayment)
    switch flow {
    case .exchange:
      guard let exchangeProduct = exchangeProduct else {
        return nil
      }
      let secondItemPayment = paymentString(for: exchangeProduct.leasingInfo.monthPay)
      let secondItem = QuestionnaireProductInfoItemViewModel(imageURL: exchangeProduct.primaryImage,
                                                             productName: exchangeProduct.name,
                                                             payment: secondItemPayment)
      return QuestionaireProductInfoViewType.exchange(firstItem: firstItem,
                                                      secondItem: secondItem)
    case .return:
      return QuestionaireProductInfoViewType.return(item: firstItem)
    }
  }
  
  private func makeProductQuestionnaireViewModel() -> ProductQuestionnaireViewModel? {
    guard let questionnaireResponse = questionnaireResponse else {
      return nil
    }
    return ProductQuestionnaireViewModel(items: makeQuestionnaireItems(from: questionnaireResponse.questions))
  }
  
  private func makeQuestionnaireItems(from questions: [Question]) -> [QuestionnaireItemViewModel] {
    return questions.sorted { $0.sortOrder < $1.sortOrder }.map { question -> QuestionnaireItemViewModel in
      let answerTypes = [
        QuestionnaireAnswerType.yes,
        QuestionnaireAnswerType.hasDisadvantages
      ]
      let answers = answerTypes.map { QuestionnaireAnswerViewModel(type: $0).pickerItemViewModel }
      return QuestionnaireItemViewModel(title: question.questionText, description: question.description,
                                        answers: answers) { [weak self] answerIndex in
        self?.selectOrDeselect(answerAt: answerIndex, for: question)
      }
    }
  }
  
  private func selectOrDeselect(answerAt index: Int,
                                for question: Question) {
    guard let answerType = QuestionnaireAnswerType(rawValue: index) else { return }
    switch answerType {
    case .yes:
      hasDisadvantagesQuestions.remove(question)
    case .hasDisadvantages:
      hasDisadvantagesQuestions.insert(question)
    }
  }
  
  private func paymentString(for monthPay: Decimal?) -> String? {
    guard let priceString = monthPay?.priceString() else { return nil }
    return R.string.questionnaire.monthPayment(priceString)
  }
  
  private func getGradeInfo() -> QuestionGradeInfo? {
    guard let questionnaireResponse = questionnaireResponse else {
      return nil
    }
    let answersSum = hasDisadvantagesQuestions.map { $0.answerValue }.reduce(0, +)
    var gradeInfo: QuestionGradeInfo?
    let gradeInfos = questionnaireResponse.gradeInfos
    for (index, grade) in gradeInfos.enumerated() {
      if grade.gradeValue < answersSum {
        if index == gradeInfos.count - 1 {
          gradeInfo = grade
          break
        } else {
          continue
        }
      } else if grade.gradeValue > answersSum {
        if index == 0 {
          gradeInfo = grade
          break
        } else {
          gradeInfo = gradeInfos.element(at: index - 1)
          break
        }
      } else {
        gradeInfo = grade
        break
      }
    }
    // TODO - refactor
    return gradeInfo
  }
}
