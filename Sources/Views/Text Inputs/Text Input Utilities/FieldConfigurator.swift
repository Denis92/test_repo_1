//
//  FieldConfigurator.swift
//  ForwardLeasing
//

import UIKit

class FieldConfigurator<T: FieldType> {
  // MARK: - Callbacks

  var onDidRequestUpdateState: (() -> Void)?
  var onDidClearText: ((_ textInput: TextInput) -> Void)?
  var onDidBeginEditing: ((_ textInput: TextInput) -> Void)?
  var onShouldBeginEditing: ((_ textInput: TextInput) -> Bool)?
  var onDidEndEditing: ((_ textInput: TextInput) -> Void)?
  var onDidChangeText: ((_ text: String?) -> Void)?
  var onValidityUpdated: ((_ isValid: Bool) -> Void)?
  var onShouldNotBeginEditing: ((_ textInput: TextInput) -> Void)?
  var onShouldReturn: (() -> Void)?
  
  // MARK: - Callbacks for text input view

  var onNeedsToChangeText: ((_ text: String?) -> Void)?
  var onDidRequestReturn: ((_ textInput: TextInput) -> Void)?
  var onDidEncounterValidationError: ((_ errorDescription: String?) -> Void)?
  var onDidRequestResetToDefault: (() -> Void)?
  var onChangeTextEditHiddenStateRequested: ((_ isHidden: Bool) -> Void)?
  var onChangeTextEditEnabledStateRequested: ((_ isEnabled: Bool) -> Void)?

  // MARK: - Properties

  private var dateFormatter: DateFormatter? {
    if case TextInputType.datePicker(_, _, _, let formatter) = textInputType {
      return formatter
    }
    return nil
  }

  private lazy var validator: TextInputValidator? = TextInputValidatorFactory.makeValidator(for: type.validatorType)

  private lazy var textInputFormatter: TextInputFormatter? = {
    return TextInputFormatterFactory.makeFormatter(for: type.formatterType)
  }()

  private var onChangeTextWorkItem: DispatchWorkItem?

  private (set) var text: String?
  var date: Date? {
    return date(from: text)
  }

  private (set) var isHidden: Bool = false {
    didSet {
      guard isHidden != oldValue else {
        return
      }
      onChangeTextEditHiddenStateRequested?(isHidden)
    }
  }

  private (set) var isEnabled: Bool {
    didSet {
      guard isEnabled != oldValue else {
        return
      }
      onChangeTextEditEnabledStateRequested?(isEnabled)
    }
  }
  
  let pickerOptions: [String]
  let title: String?
  var forceNextCheckSilent = false
  let type: T
  var textInputType: TextInputType {
    return type.textInputType
  }
  let hint: String?
  let shouldAnimateEditingStart: Bool
  let scrollToFieldWhenEditingNotAllowed: Bool
  
  var keyboardType: UIKeyboardType {
    return type.keyboardType
  }

  var textContentType: UITextContentType? {
    return type.textContentType
  }

  var textContainerType: TextContainerType {
    return type.textContainerType
  }

  var hasClearButton: Bool {
    return type.hasClearButton
  }

  var isSecureTextEntry: Bool {
    return type.isSecureTextEntry
  }

  var hasSecureModeSwitchButton: Bool {
    return type.hasSecureModeSwitchButton
  }

  var hasDownwardChevronRightView: Bool {
    return type.hasDownwardChevronRightView
  }

  var maxCharacterCount: Int? {
    return type.formatterType?.maxCharacterCount
  }

  var sanitizedText: String? {
    guard let formatter = textInputFormatter else { return text }
    return formatter.sanitizedText(text)
  }

  var returnKeyType: UIReturnKeyType {
    return type.returnKeyType
  }

  var hasToolbar: Bool {
    return type.hasToolbar
  }

  var autocapitalizationType: UITextAutocapitalizationType {
     return type.autocapitalizationType
  }

  var hasCharacterCounter: Bool {
    return type.hasCharacterCounter
  }

  var letterSpacing: CGFloat {
    return type.letterSpacing
  }

  // MARK: - Init

  init(fieldType: T, text: String? = nil, pickerOptions: [String] = []) {
    self.text = text
    self.title = fieldType.title
    self.type = fieldType
    self.hint = fieldType.hint
    self.shouldAnimateEditingStart = fieldType.shouldAnimateEditingStart
    self.scrollToFieldWhenEditingNotAllowed = fieldType.scrollToFieldWhenEditingNotAllowed
    self.pickerOptions = pickerOptions
    self.isEnabled = fieldType.isEnabled
  }

  func update(text: String?) {
    onNeedsToChangeText?(text)
  }

  func changeTextEditHiddenState(to isHidden: Bool) {
    self.isHidden = isHidden
  }

  func changeTextEditEnabledState(to isEnabled: Bool) {
    self.isEnabled = isEnabled
  }

  func handle(error: Error) {
    onDidEncounterValidationError?(error.localizedDescription)
  }
  
  func resetToDefaultState() {
    onDidRequestResetToDefault?()
  }

  func date(from text: String?) -> Date? {
    guard let text = text else {
      return nil
    }
    return dateFormatter?.date(from: text)
  }

  // MARK: - Validation

  @discardableResult
  func validate(silent: Bool = false) -> Bool {
    let silent = forceNextCheckSilent ? true : silent
    forceNextCheckSilent = false
    do {
      try validator?.validate(sanitizedText)
      onValidityUpdated?(true)
      return true
    } catch let error {
      guard let error = error as? ValidationError else { return false }
      if !silent {
        onDidEncounterValidationError?(error.localizedDescription)
      }
      onValidityUpdated?(false)
      return false
    }
  }

  private func handleTextUpdate(textInput: TextInput) {
    guard text != textInput.text else {
      return
    }
    text = textInput.text
    textInput.resetToDefaultState()
    textInput.layoutIfNeeded()
  }
}

// MARK: - TextInputFormDelegate

extension FieldConfigurator: TextInputDelegate {
  func textInputDidBeginEditing(_ textInput: TextInput) {
    onDidBeginEditing?(textInput)
  }

  func textInputDidEndEditing(_ textInput: TextInput) {
    handleTextUpdate(textInput: textInput)
    validate(silent: false)
    onDidEndEditing?(textInput)
  }

  func textInput(_ textInput: TextInput, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    defer {
      onDidRequestUpdateState?()
    }

    textInput.resetToDefaultState()
    let text = (textInput.text ?? "") as NSString
    let expectedResult = text.replacingCharacters(in: range, with: string)

    if let formatter = textInputFormatter, !string.isEmpty {
      var shouldChangeCharacters = false
      if formatter.shouldChangeCharacters(in: range, originalString: text as String,
                                          replacementString: string) {
        if formatter.shouldFormatText(expectedResult) {
          let formattedText = formatter.formattedText(expectedResult)
          if formattedText != expectedResult {
            textInput.updateText(to: formattedText, force: true)
          } else {
            shouldChangeCharacters = true
          }
        } else {
          shouldChangeCharacters = true
        }
      }
      return shouldChangeCharacters
    }

    return true
  }

  func textInputShouldReturn(_ textInput: TextInput) -> Bool {
    onDidRequestReturn?(textInput)
    onShouldReturn?()
    return true
  }

  func textInputShouldBeginEditing(_ textInput: TextInput) -> Bool {
    let shouldBegin = onShouldBeginEditing?(textInput) ?? true
    if !shouldBegin {
      onShouldNotBeginEditing?(textInput)
    }
    return shouldBegin
  }

  func textInputEditingChanged(_ textInput: TextInput) {
    onChangeTextWorkItem?.cancel()

    if let formatter = textInputFormatter, let text = textInput.text, !text.isEmpty {
      let formattedText = formatter.formattedText(text)
      if formattedText != text {
        textInput.updateText(to: formattedText)
      }
    }

    text = textInput.text

    let work = DispatchWorkItem { [weak self] in
      guard let self = self else { return }
      self.onDidChangeText?(self.text)
      self.onChangeTextWorkItem = nil
    }
    onChangeTextWorkItem = work

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: work)

    if !textInput.text.isEmptyOrNil {
      handleTextUpdate(textInput: textInput)
    }
  }

  func textInputDidClearText(_ textInput: TextInput) {
    text = nil
    onDidClearText?(textInput)
  }
}
