//
//  QuestionnaireResultViewModelsFactory.swift
//  ForwardLeasing
//

import Foundation

private extension Constants {
  static let maxNumberOfStars = 5
}

struct QuestionnaireResultViewModelsFactory {
  func makeStarsViewModel(gradeInfo: QuestionGradeInfo) -> StarsViewModel {
    return StarsViewModel(numberOfStars: gradeInfo.gradeType.rating,
                          maxNumberOfStars: Constants.maxNumberOfStars)
  }
  
  func makePriceListViewModel(gradeInfo: QuestionGradeInfo,
                              questionnaireFormatter: QuestionnaireFormatter,
                              earlyPriceDescription: String) -> PriceListViewModel {
    
    let items = gradeInfo.gradeType == .none
      ? []
      : [
        PriceListItemViewModel(price: questionnaireFormatter.earlyUpgradePrice,
                               description: earlyPriceDescription),
        PriceListItemViewModel(price: questionnaireFormatter.diagnosticPrice,
                               description: R.string.questionnaire.afterDiagnosticsPriceDescription()),
        PriceListItemViewModel(price: questionnaireFormatter.finalPrice,
                               description: R.string.questionnaire.finalPriceDescription())
      ]
    return PriceListViewModel(items: items)
  }
}
