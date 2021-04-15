//
//  QuestionnaireItemViewModel.swift
//  ForwardLeasing
//

import UIKit

class QuestionnaireItemViewModel: QuestionnaireItemViewModelProtocol {
  let title: String?
  let description: String?
  let answers: [ProductPropertyPickerItemViewModel]
  let onDidSelectAnswerAtIndex: ((Int) -> Void)?
  
  init(title: String?, description: String?,
       answers: [ProductPropertyPickerItemViewModel],
       onDidSelectAnswerAtIndex: ((Int) -> Void)?) {
    self.title = title
    self.description = description
    self.answers = answers
    self.onDidSelectAnswerAtIndex = onDidSelectAnswerAtIndex
    answers.forEach {
      $0.delegate = self
    }
  }
}

// MARK: - ProductPropertyPickerItemViewModelDelegate
extension QuestionnaireItemViewModel: ProductPropertyPickerItemViewModelDelegate {
  func productPropertyPickerItemViewModel(_ viewModel: ProductPropertyPickerItemViewModel,
                                          didSetSelectedStateTo isSelected: Bool) {
    guard isSelected, let selectedIndex = answers.firstIndex(where: { $0 === viewModel }) else {
      return
    }
    answers.filter { $0 !== viewModel }.forEach { $0.setSelected(to: false) }
    onDidSelectAnswerAtIndex?(selectedIndex)
  }
}
