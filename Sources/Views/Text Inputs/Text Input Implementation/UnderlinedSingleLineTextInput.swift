//
//  UnderlinedSingleLineTextInput.swift
//  ForwardLeasing
//

import UIKit

private extension Constants {
  static let height: CGFloat = 46
  static let underlineHeight: CGFloat = 1.5
}

class UnderlinedSingleLineTextInput: UIView, TextInput {
  // MARK: - Properties
  var storedErrorText: String?
  var storedHint: String?
  var state: TextInputState = .inactive
  var titleState: TitleState = .title
  var shouldAnimateEditingStart = true
  var shouldBecomeFirstResponder = true
  var shouldUpdateAppearance = false
  var hasClearButton: Bool = false
  var maskLayer: CAShapeLayer?

  weak var delegate: TextInputDelegate?

  var onChangedHintOrErrorHeight: (() -> Void)?

  var text: String? {
    get { return textField.text }
    set {
      textField.text = newValue
      textField.sendActions(for: .editingChanged)
    }
  }

  var textContainerType: TextContainerType {
    return .underscoredSingleLine
  }

  var returnKeyType: UIReturnKeyType {
    get { return textField.returnKeyType }
    set { textField.returnKeyType = newValue }
  }

  var autocapitalizationType: UITextAutocapitalizationType {
    get { return textField.autocapitalizationType }
    set { textField.autocapitalizationType = newValue }
  }

  var keyboardType: UIKeyboardType {
    get { return textField.keyboardType }
    set { textField.keyboardType = newValue }
  }

  var isSecureTextEntry: Bool {
    get { return textField.isSecureTextEntry }
    set {
      textField.isSecureTextEntry = newValue
    }
  }

  var autocorrectionType: UITextAutocorrectionType {
    get { return textField.autocorrectionType }
    set { textField.autocorrectionType = newValue }
  }

  var textContentType: UITextContentType? {
    get { return textField.textContentType }
    set { textField.textContentType = newValue }
  }

  var isEditing: Bool {
    return textField.isFirstResponder
  }

  override var isFirstResponder: Bool {
    return textField.isFirstResponder
  }

  // MARK: - Subviews

  let containerStackView = UIStackView()
  let titleLabel = AttributedLabel(textStyle: .textRegular)
  let hintOrErrorLabel = AttributedLabel(textStyle: .footnoteRegular)
  let textInputViewContainer = UIView()
  var underlineView: UIView? = UIView()

  var textInputView: TextInputView {
    return textField
  }

  private let textField: UITextField
  private var tapGesture: UITapGestureRecognizer?

  // MARK: - Init

  init(inputType: TextInputType = .keyboard) {
    textField = UITextField()
    textField.tintColor = .accent

    super.init(frame: .zero)
    setup()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Override
  @discardableResult
  override func becomeFirstResponder() -> Bool {
    return textField.becomeFirstResponder()
  }

  @discardableResult
  override func resignFirstResponder() -> Bool {
    return textField.resignFirstResponder()
  }

  // MARK: - Setup

  func setInputAccessoryView(_ view: UIView?) {
    textField.inputAccessoryView = view
  }

  // MARK: - Add Subviews

  func setupTextEdit() {
    textInputViewContainer.addSubview(textField)
    textField.delegate = self
    textField.addTarget(self, action: #selector(handleEditingChanged), for: .editingChanged)
    textField.snp.makeConstraints { make in
      make.height.equalTo(Constants.height)
      make.leading.trailing.equalToSuperview()
      make.top.equalToSuperview().offset(20)
    }
    textField.font = .title3Semibold
    underlineView.map { textInputViewContainer.addSubview($0) }
    underlineView?.snp.makeConstraints { make in
      make.top.equalTo(textField.snp.bottom).offset(2)
      make.leading.trailing.bottom.equalToSuperview()
      make.height.equalTo(Constants.underlineHeight)
    }
  }

  func additionalSetup<T: FieldType>(with configurator: FieldConfigurator<T>) {
    textField.defaultTextAttributes.updateValue(configurator.letterSpacing, forKey: NSAttributedString.Key.kern)
  }

  // MARK: - Update text

  func updateText(to newText: String?) {
    updateText(to: newText, force: false)
  }

  func updateText(to newText: String?, force: Bool) {
    let text = self.text ?? ""
    let range = NSRange(text.startIndex..., in: text)
    if force {
      self.text = newText
    } else if delegate?.textInput(self, shouldChangeCharactersIn: range, replacementString: newText ?? "") ?? true {
      self.text = newText
    }
    if !isEditing {
      updateTitleStateForNoTextIfNeeded()
    }
  }
}

// MARK: - Actions

extension UnderlinedSingleLineTextInput {
  @objc func handleEditingChanged() {
    delegate?.textInputEditingChanged(self)
  }
}

// MARK: - Public Methods

extension UnderlinedSingleLineTextInput {
  func resetTitleConstraints() {
    titleLabel.snp.remakeConstraints { make in
      make.trailing.leading.top.equalTo(textInputViewContainer)
    }
    titleState = .title
  }

  func makeTextInputFirstResponder() {
    textField.becomeFirstResponder()
  }
}

// MARK: - UITextFieldDelegate

extension UnderlinedSingleLineTextInput: UITextFieldDelegate {
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    let shouldBegin = delegate?.textInputShouldBeginEditing(self) ?? true
    if shouldBegin {
      handleEditingBeginning()
    }
    return shouldBegin
  }

  func textFieldDidBeginEditing(_ textField: UITextField) {
    handleEditingChanged()
    delegate?.textInputDidBeginEditing(self)
  }

  func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
    let shouldEnd = delegate?.textInputShouldEndEditing(self) ?? true
    if shouldEnd {
      handleShouldEndEditingState()
    }
    return shouldEnd
  }

  func textFieldDidEndEditing(_ textField: UITextField) {
    delegate?.textInputDidEndEditing(self)
  }

  func textField(_ textField: UITextField,
                 shouldChangeCharactersIn range: NSRange,
                 replacementString string: String) -> Bool {
    return delegate?.textInput(self, shouldChangeCharactersIn: range, replacementString: string) ?? true
  }

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    return delegate?.textInputShouldReturn(self) ?? true
  }
}
