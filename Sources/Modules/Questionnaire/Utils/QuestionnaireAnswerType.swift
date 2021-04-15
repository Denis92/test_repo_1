//
//  QuestionnaireAnswerType.swift
//  ForwardLeasing
//

import Foundation

enum QuestionnaireAnswerType: Int {
  case yes
  case hasDisadvantages
}

struct QuestionnaireAnswerViewModel {
  let pickerItemViewModel: ProductPropertyPickerItemViewModel
  
  init(type: QuestionnaireAnswerType) {
    switch type {
    case .yes:
      pickerItemViewModel = ProductPropertyPickerItemViewModel(title: R.string.common.yes(),
                                                               isSelected: true)
    case .hasDisadvantages:
      pickerItemViewModel = ProductPropertyPickerItemViewModel(title: R.string.questionnaire.hasDisadvantagesTitle())
    }
  }
}
