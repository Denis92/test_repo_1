//
//  RadioButtonsHaving.swift
//  ForwardLeasing
//

import Foundation

protocol RadioButtonsHaving: class {
  var radioButtonGroups: [String: [RadioButton]] { get set }
  func add(_ radioButton: RadioButton, toGroupWithIdentifier identifier: String)
  func didSelectRadioButton(_ radioButton: RadioButton, groupIdentifier: String)
}

extension RadioButtonsHaving {
  func add(_ radioButton: RadioButton, toGroupWithIdentifier identifier: String) {
    if radioButtonGroups[identifier] == nil {
      radioButtonGroups[identifier] = [radioButton]
    } else {
      radioButtonGroups[identifier]?.append(radioButton)
    }
    
    radioButton.onDidChangeValue = { [weak self] radioButton in
      if radioButton.isSelected {
        self?.didSelectRadioButton(radioButton, groupIdentifier: identifier)
      }
    }
  }
  
  func didSelectRadioButton(_ radioButton: RadioButton, groupIdentifier: String) {
    radioButtonGroups[groupIdentifier]?.forEach { button in
      if button != radioButton && button.isSelected {
        button.isSelected = false
      }
    }
  }
  
  func selectedRadioButton(inGroupWithIdentifier identifier: String) -> RadioButton? {
    return radioButtonGroups[identifier]?.first { $0.isSelected }
  }
}
