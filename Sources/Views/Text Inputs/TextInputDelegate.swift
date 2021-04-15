//
//  TextInputDelegate.swift
//  ForwardLeasing
//

import Foundation

protocol TextInputDelegate: class {
  func textInputShouldBeginEditing(_ textInput: TextInput) -> Bool
  func textInputDidBeginEditing(_ textInput: TextInput)
  func textInputShouldEndEditing(_ textInput: TextInput) -> Bool
  func textInputDidEndEditing(_ textInput: TextInput)
  func textInput(_ textInput: TextInput,
                 shouldChangeCharactersIn range: NSRange,
                 replacementString string: String) -> Bool
  func textInputShouldReturn(_ textInput: TextInput) -> Bool
  func textInputEditingChanged(_ textInput: TextInput)
  func textInputDidClearText(_ textInput: TextInput)
}

extension TextInputDelegate {
  func textInputShouldBeginEditing(_ textInput: TextInput) -> Bool { return true }
  func textInputDidBeginEditing(_ textInput: TextInput) {}
  func textInputShouldEndEditing(_ textInput: TextInput) -> Bool { return true }
  func textInputDidEndEditing(_ textInput: TextInput) {}
  func textInput(_ textInput: TextInput,
                 shouldChangeCharactersIn range: NSRange,
                 replacementString string: String) -> Bool { return true }
  func textInputShouldReturn(_ textInput: TextInput) -> Bool { return true }
  func textInputEditingChanged(_ textInput: TextInput) {}
  func textInputDidClearText(_ textInput: TextInput) {}
}
