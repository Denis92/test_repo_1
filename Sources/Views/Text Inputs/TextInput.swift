//
//  TextInput.swift
//  ForwardLeasing
//

import UIKit

enum TextInputState {
  case active, inactive, activeError(errorText: String?), inactiveError(errorText: String?), disabled
}

enum TitleState {
  case placeholder, title
}

// MARK: - TextInput protocol definition

protocol TextInputView where Self: UIView {
  var textColor: UIColor? { get set }
  var isEnabled: Bool { get set }
}

extension UITextField: TextInputView { }

protocol TextInput where Self: UIView {
  var textContainerType: TextContainerType { get }

  var maskLayer: CAShapeLayer? { get set }
  var shouldAnimateEditingStart: Bool { get  set }
  var shouldBecomeFirstResponder: Bool { get }
  var shouldUpdateAppearance: Bool { get set }

  var autocapitalizationType: UITextAutocapitalizationType { get set }
  var autocorrectionType: UITextAutocorrectionType { get set }
  var textContentType: UITextContentType? { get set }
  var returnKeyType: UIReturnKeyType { get set }
  var keyboardType: UIKeyboardType { get set }
  
  var text: String? { get set }
  var title: String? { get set }
  var hintText: String? { get }
  var storedHint: String? { get set }

  var hasClearButton: Bool { get set }
  var isSecureTextEntry: Bool { get set }
  var isEditing: Bool { get }
  var state: TextInputState { get set }
  var titleState: TitleState { get set }
  var onChangedHintOrErrorHeight: (() -> Void)? { get set }

  var containerStackView: UIStackView { get }
  var textInputViewContainer: UIView { get }
  var titleLabel: AttributedLabel { get }
  var hintOrErrorLabel: AttributedLabel { get }
  var underlineView: UIView? { get }
  var textInputView: TextInputView { get }

  var delegate: TextInputDelegate? { get set }

  func makeTextInputFirstResponder()
  func resetTitleConstraints()
  func setupTextEdit()
  func setupAdditionalViews()
  func startEditing()
  func setInputAccessoryView(_ view: UIView?)
  func handleEditingChanged()
  func updateText(to newText: String?)
  func updateText(to newText: String?, force: Bool)
  func configure(for state: TextInputState)
  func setup<T: FieldType>(with configurator: FieldConfigurator<T>)
  func additionalSetup<T: FieldType>(with configurator: FieldConfigurator<T>)
}
