//
//  TextInputContaining.swift
//  ForwardLeasing
//

import UIKit

// MARK: - InputFormContainer

enum TextFieldPosition {
  case top
  case bottom
}

protocol TextInputContaining: KeyboardVisibilityHandler {
  associatedtype ContainerFieldType: FieldType

  var isUpdatingBottomInsetWithAnimation: Bool { get }
  var scrollView: UIScrollView { get }
  var textInputStackView: UIStackView { get }
  var textInputContainers: [(textInput: TextInput, type: ContainerFieldType)] { get set }
  var currentKeyboardHeight: CGFloat { get set }
  var scrollViewTopInset: CGFloat { get }

  func createTextInput(for configurator: FieldConfigurator<ContainerFieldType>) -> TextInput
  func createTextInput(for configurator: FieldConfigurator<ContainerFieldType>,
                       customize: ((_ textInput: TextInput, _ type: ContainerFieldType) -> Void)?) -> TextInput

  func setFocusToPreviousResponder(forResponderWith type: ContainerFieldType)
  func setFocusToNextResponder(forResponderWith type: ContainerFieldType)

  func moveScrollToFirstResponder()
  func handleTextInputBottomTextUpdated()

  func handleKeyboardDoneButtonTapped()
  func handleContentInsetUpdated()
}

extension TextInputContaining {
  var isUpdatingBottomInsetWithAnimation: Bool {
    return true
  }

  func handleContentInsetUpdated() {
    // do nothinfg by default
  }
}

extension TextInputContaining where Self: UIViewController {
  var scrollViewTopInset: CGFloat {
    return 0
  }
  
  func handleTextInputBottomTextUpdated() {
    // do nothing by default
  }

  func handleKeyboardDoneButtonTapped() {
    // do nothing by default
  }

  func createTextInput(for configurator: FieldConfigurator<ContainerFieldType>,
                       customize: ((_ textInput: TextInput, _ type: ContainerFieldType) -> Void)?) -> TextInput {
    let textInput: TextInput

    switch configurator.textContainerType {
    case .outlinedSingleLine:
      textInput = OutlinedSingleLineTextInput(inputType: configurator.textInputType)
    case .underscoredSingleLine:
      textInput = UnderlinedSingleLineTextInput()
    }

    configure(textInput: textInput, with: configurator, customize: customize)

    configurator.onDidRequestReturn = { [weak self, unowned configurator] textInput in
      self?.handleTextInputReturnRequested(configurator: configurator, textInput: textInput)
    }
    configurator.onShouldNotBeginEditing = { [weak self, unowned configurator] textInput in
      guard configurator.scrollToFieldWhenEditingNotAllowed else {
        return
      }
      self?.moveScroll(to: textInput)
    }
    configurator.onDidBeginEditing = { [weak self] textInput in
      self?.moveScroll(to: textInput)
    }
    textInputContainers.append((textInput, configurator.type))
    return textInput
  }

  func setupFullWidthTextInput(textInput: TextInput) {
    if let lastView = textInputStackView.arrangedSubviews.last {
      textInputStackView.setCustomSpacing(16, after: lastView)
    }
    textInputStackView.addArrangedSubview(textInput)
  }
  
  func createTextInput(for configurator: FieldConfigurator<ContainerFieldType>) -> TextInput {
    return createTextInput(for: configurator, customize: nil)
  }

  func setFocusToPreviousResponder(forResponderWith type: ContainerFieldType) {
    var prevType = type.previousFieldType
    while prevType?.isEnabled == false {
      prevType = prevType?.previousFieldType
    }
    changeFirstResponder(toResponderWith: prevType)
  }

  func setFocusToNextResponder(forResponderWith type: ContainerFieldType) {
    var nextType = type.nextFieldType
    while nextType?.isEnabled == false {
      nextType = nextType?.nextFieldType
    }
    changeFirstResponder(toResponderWith: nextType)
  }

  func moveScrollToFirstResponder() {
    guard let textInputContainer = textInputContainers.first(where: { $0.textInput.isFirstResponder }) else { return }
    moveScroll(to: textInputContainer.textInput)
  }
  
  func updateBottomInset() {
    if self.currentKeyboardHeight == 0 {
      self.scrollView.contentInset = UIEdgeInsets(top: scrollViewTopInset, left: 0, bottom: 0, right: 0)
      handleContentInsetUpdated()
    } else {
      self.moveScrollToFirstResponder()
    }
  }
  
  func moveScroll(to textInput: TextInput, textFieldPosition: TextFieldPosition = .bottom,
                  completion: (() -> Void)? = nil) {
    let convertedRect = scrollView.convert(textInput.frame, from: textInput.superview ?? textInput)
    var scrollOffset: CGPoint?
    if textFieldPosition == .bottom {
      scrollOffset = scrollToBottomPositionOffset(with: convertedRect)
    } else {
      scrollOffset = scrollToTopPostionOffset(with: convertedRect)
    }
    guard let offset = scrollOffset else { return }
    if isUpdatingBottomInsetWithAnimation {
      UIView.animate(withDuration: 0.3, animations: {
        self.scrollView.setContentOffset(offset, animated: false)
      }, completion: { _ in
        completion?()
      })
    } else {
      UIView.performWithoutAnimation {
        self.scrollView.setContentOffset(offset, animated: false)
      }
    }
  }
  
  private func scrollToTopPostionOffset(with convertedRect: CGRect) -> CGPoint {
    let topPointY = convertedRect.minY + 8
    let offset = CGPoint(x: 0, y: topPointY)
    return offset
  }
  
  private func scrollToBottomPositionOffset(with convertedRect: CGRect) -> CGPoint? {
    let bottomPointY = convertedRect.maxY + 8
    let scrollViewVisibleHeight = scrollView.bounds.height - currentKeyboardHeight
      - scrollView.contentInset.top
    var offset = CGPoint(x: 0, y: max(0, bottomPointY - scrollViewVisibleHeight))

    if scrollView.contentOffset.y <= convertedRect.minY
      && scrollView.contentOffset.y + scrollViewVisibleHeight > bottomPointY {
      return nil
    }

    if scrollView.contentOffset.y > convertedRect.minY {
      offset = CGPoint(x: 0, y: max(0, convertedRect.minY - 8))
    }
    return offset
  }

  private func configure(textInput: TextInput, with configurator: FieldConfigurator<ContainerFieldType>,
                         customize: ((_ textInput: TextInput, _ type: ContainerFieldType) -> Void)?) {
    textInput.autocorrectionType = .no
    textInput.setup(with: configurator)
    customize?(textInput, configurator.type)
    textInput.onChangedHintOrErrorHeight = { [weak self] in
      self?.handleTextInputBottomTextUpdated()
    }
    if configurator.hasToolbar {
      textInput.setupTextInputToolbar(type: configurator.type,
                                      onDidTapNext: { [weak self] in
        self?.setFocusToNextResponder(forResponderWith: configurator.type)
      }, onDidTapPrev: { [weak self] in
        self?.setFocusToPreviousResponder(forResponderWith: configurator.type)
      }, onDidTapDone: { [weak self] in
        if configurator.type.isLast || configurator.type.returnKeyType == .done {
          self?.handleKeyboardDoneButtonTapped()
        }
        self?.view.endEditing(true)
      })
    }
  }

  private func handleTextInputReturnRequested(configurator: FieldConfigurator<ContainerFieldType>,
                                              textInput: TextInput) {
    guard !configurator.type.isLast, configurator.type.returnKeyType != .done  else {
      textInput.resignFirstResponder()
      handleKeyboardDoneButtonTapped()
      return
    }

    if configurator.type.returnKeyType == .next {
      setFocusToNextResponder(forResponderWith: configurator.type)
    }
  }

  private func changeFirstResponder(toResponderWith type: ContainerFieldType?) {
    guard let textInputContainer = textInputContainers.first(where: { $0.type == type }) else {
      view.endEditing(true)
      return
    }
    textInputContainer.textInput.becomeFirstResponder()
    moveScroll(to: textInputContainer.textInput)
  }

  // MARK: - Keyboard notifications

  func keyboardWillShow(_ keyboardInfo: KeyboardInfo) {
    updateScrollViewBottomInset(withKeyboardInfo: keyboardInfo, willHide: false)
  }

  func keyboardWillHide(_ keyboardInfo: KeyboardInfo) {
    updateScrollViewBottomInset(withKeyboardInfo: keyboardInfo, willHide: true)
  }

  func keyboardWillChangeFrame(_ keyboardInfo: KeyboardInfo) {
    updateScrollViewBottomInset(withKeyboardInfo: keyboardInfo, willHide: false)
  }
  
  private func updateScrollViewBottomInset(withKeyboardInfo keyboardInfo: KeyboardInfo,
                                           willHide: Bool) {
    currentKeyboardHeight = keyboardInfo.keyboardVisibleHeight
    updateScrollViewContentInset()
    if isUpdatingBottomInsetWithAnimation {
      UIView.setAnimationCurve(keyboardInfo.animationCurve)
      UIView.animate(withDuration: keyboardInfo.animationDuration, delay: 0, options: [], animations: {
        self.view.layoutIfNeeded()
      }, completion: { _ in
        self.updateBottomInset()
      })
    } else {
      UIView.performWithoutAnimation {
        self.view.layoutIfNeeded()
        self.updateBottomInset()
      }
    }
  }

  private func updateScrollViewContentInset() {
    if scrollView.contentSize.height + currentKeyboardHeight + scrollViewTopInset >= scrollView.frame.height,
       scrollView.frame.height > 0 {
      scrollView.contentInset = UIEdgeInsets(top: scrollViewTopInset, left: 0, bottom: currentKeyboardHeight, right: 0)
      handleContentInsetUpdated()
    }
  }
}
