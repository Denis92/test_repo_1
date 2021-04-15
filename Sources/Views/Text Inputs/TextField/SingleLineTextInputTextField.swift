//
//  SingleLineTextInputTextField.swift
//  ForwardLeasing
//

import UIKit

private extension Constants {
  static let insets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
  static let font: UIFont = .textRegular
  static let textColor: UIColor = .base1
}

class SingleLineTextInputTextField: UITextField {
  // MARK: - Properties
  var textInsets: UIEdgeInsets = Constants.insets
  private let shouldHideCaret: Bool

  private var adjustedInsets: UIEdgeInsets {
    var insets = textInsets
    if let view = rightView, isEditing && (rightViewMode == .always || rightViewMode == .whileEditing)
      || !isEditing && (rightViewMode == .always || rightViewMode == .unlessEditing) {
      insets.right = view.frame.width - textInsets.right
    }
    if let view = leftView, isEditing && (leftViewMode == .always || leftViewMode == .whileEditing)
    || !isEditing && (leftViewMode == .always || leftViewMode == .unlessEditing) {
      insets.left = view.frame.width - textInsets.left
    }
    return insets
  }

  // MARK: - Init

  init(insets: UIEdgeInsets = Constants.insets, shouldHideCaret: Bool = false) {
    self.shouldHideCaret = shouldHideCaret
    super.init(frame: .zero)
    setup()
  }

  override init(frame: CGRect) {
    self.shouldHideCaret = false
    super.init(frame: frame)
    setup()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Ovrerides

  override func caretRect(for position: UITextPosition) -> CGRect {
    guard shouldHideCaret else {
      return super.caretRect(for: position)
    }
    return .zero
  }

  // MARK: - Setup

  func setup() {
    font = Constants.font
    textColor = Constants.textColor
  }

  // MARK: - Override

  override open func textRect(forBounds bounds: CGRect) -> CGRect {
    return bounds.inset(by: adjustedInsets)
  }

  override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
    return bounds.inset(by: adjustedInsets)
  }

  override open func editingRect(forBounds bounds: CGRect) -> CGRect {
    return bounds.inset(by: adjustedInsets)
  }
}
