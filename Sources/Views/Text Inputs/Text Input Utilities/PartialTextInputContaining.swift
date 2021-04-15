//
//  PartialTextInputContaining.swift
//  ForwardLeasing
//

import UIKit

protocol PartialTextInputContaining {
  @discardableResult
  func setupPatrialWidthStretchingTextInput(textInput: TextInput, position: PartialWidthLayoutPosition,
                                            to currentHorizontalStackView: inout UIStackView?) -> UIView
  @discardableResult
  func setupPartialWidthFixedTextInput<T: FieldType>(textInput: TextInput, width: CGFloat, position: PartialWidthLayoutPosition,
                                                     textConfigurator: FieldConfigurator<T>,
                                                     to currentHorizontalStackView: inout UIStackView?) -> UIView
}

extension PartialTextInputContaining where Self: UIViewController & TextInputContaining  {
  @discardableResult
  func setupPatrialWidthStretchingTextInput(textInput: TextInput, position: PartialWidthLayoutPosition,
                                            to currentHorizontalStackView: inout UIStackView?) -> UIView {
    let horizontalStackView = position == .last ? currentHorizontalStackView : createHorizontalStackView()
    let textInputContainer = UIView()
    textInputContainer.addSubview(textInput)
    textInput.snp.makeConstraints { make in
      make.leading.top.trailing.equalToSuperview()
      make.bottom.lessThanOrEqualToSuperview()
    }
    horizontalStackView?.addArrangedSubview(textInputContainer)
    
    if position == .first {
      horizontalStackView?.setCustomSpacing(24, after: textInputContainer)
      currentHorizontalStackView = horizontalStackView
    } else {
      if let lastView = textInputStackView.arrangedSubviews.last {
        textInputStackView.setCustomSpacing(16, after: lastView)
      }
      horizontalStackView.map { textInputStackView.addArrangedSubview($0) }
    }
    return textInputContainer
  }
  
  @discardableResult
  func setupPartialWidthFixedTextInput<T: FieldType>(textInput: TextInput, width: CGFloat, position: PartialWidthLayoutPosition,
                                                     textConfigurator: FieldConfigurator<T>,
                                                     to currentHorizontalStackView: inout UIStackView?) -> UIView {
    let textInputContainer = UIView()
    textInputContainer.addSubview(textInput)
    textInput.snp.makeConstraints { make in
      make.leading.top.trailing.equalToSuperview()
      make.bottom.lessThanOrEqualToSuperview()
      make.width.equalTo(width)
    }
    let horizontalStackView = position == .last ? currentHorizontalStackView : createHorizontalStackView()
    horizontalStackView?.addArrangedSubview(textInputContainer)
    
    if let horizontalStackView = horizontalStackView {
      textInput.onChangedHintOrErrorHeight = { [weak self] in
        horizontalStackView.setNeedsLayout()
        self?.view.layoutIfNeeded()
      }
    }
    
    if position == .first {
      horizontalStackView?.setCustomSpacing(24, after: textInputContainer)
      currentHorizontalStackView = horizontalStackView
    } else {
      if let lastView = textInputStackView.arrangedSubviews.last {
        textInputStackView.setCustomSpacing(16, after: lastView)
      }
      horizontalStackView.map { textInputStackView.addArrangedSubview($0) }
    }
    return textInputContainer
  }
  
  func setupTextFields<T: LayoutedFieldType>(with configurators: [FieldConfigurator<T>],
                                             configureTextInput: ((_ configurator: FieldConfigurator<T>,
                                                                   _ textInputContainer: UIView,
                                                                   _ horizontalStackView: UIStackView?) -> Void)?)
  where T == Self.ContainerFieldType {
    var currentHorizontalStackView: UIStackView?
    for textConfigurator in configurators {
      let textInput = createTextInput(for: textConfigurator)
      switch textConfigurator.type.textInputLayoutType {
      case .fullWidth:
        setupFullWidthTextInput(textInput: textInput)
        configureTextInput?(textConfigurator, textInput, currentHorizontalStackView)
      case .partialWidthStretching(let position):
        let textInputContainer = setupPatrialWidthStretchingTextInput(textInput: textInput, position: position,
                                                                      to: &currentHorizontalStackView)
        configureTextInput?(textConfigurator, textInputContainer, currentHorizontalStackView)
      case .partialWidthFixed(let width, let position):
        let textInputContainer = setupPartialWidthFixedTextInput(textInput: textInput, width: width, position: position,
                                                                 textConfigurator: textConfigurator,
                                                                 to: &currentHorizontalStackView)
        configureTextInput?(textConfigurator, textInputContainer, currentHorizontalStackView)
        currentHorizontalStackView = nil
      }
      textInput.layoutIfNeeded()
    }
    textInputStackView.layoutIfNeeded()
  }
  
  private func createHorizontalStackView() -> UIStackView {
    let horizontalStackView = UIStackView()
    horizontalStackView.axis = .horizontal
    return horizontalStackView
  }
}
