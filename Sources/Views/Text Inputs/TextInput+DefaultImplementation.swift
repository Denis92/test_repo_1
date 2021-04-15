//
//  TextInput+DefaultImplementation.swift
//  ForwardLeasing
//

import UIKit

// MARK: - TextInput Constants

private extension Constants {
  static let placeholderTextStyle: TextStyle = .textRegular
  static let titleTextStyle: TextStyle = .footnoteRegular

  static let placeholderColor: UIColor = .shade70
  static let hintColor: UIColor = .shade70
  static let backgroundColor: UIColor = .white

  static let inactiveStateBorderColor: CGColor = UIColor.shade40.cgColor
  static let activeStateBorderColor: CGColor = UIColor.accent.cgColor
  static let errorStateBorderColor: CGColor = UIColor.error.cgColor

  static let inactiveStateUnderlineColor: UIColor = .shade40
  static let activeStateUnderlineColor: UIColor = .accent

  static let defaultTitleTextColor: UIColor = .shade70
  static let defaultTextColor: UIColor = .base1
  static let disabledTextColor: UIColor = .shade40
  static let errorTextColor: UIColor = .error
  static let activeTitleTextColor: UIColor = .accent
  static let titleLeadingOffset: CGFloat = 16
  static let titleLabelMaskInstes: CGFloat = 4
  static let fieldCornerRadius: CGFloat = 8
  static let fieldBorderWidth: CGFloat = 1.5
}

// MARK: - Shared TextInput implementation

extension TextInput {
  // MARK: - Computed Variables

  private var hasText: Bool {
    return !text.isEmptyOrNil
  }

  var title: String? {
    get { return titleLabel.text }
    set { titleLabel.text = newValue }
  }

  var hasError: Bool {
    return isErrorState(state)
  }

  var hintText: String? {
    get {
      return storedHint
    }
    set {
      storedHint = newValue
      onChangedHintOrErrorHeight?()
      guard !hasError else {
        return
      }
      hintOrErrorLabel.text = newValue
      hintOrErrorLabel.isHidden = hintOrErrorLabel.text.isEmptyOrNil
    }
  }

  // MARK: - Setup

  func setup() {
    setupContainerStackView()
    setupTextInputViewContainer()
    setupTitleLabel()
    setupTextEdit()
    setupAdditionalViews()
    setupHintOrErrorLabel()
    hintOrErrorLabel.isHidden = hintOrErrorLabel.text.isEmptyOrNil
  }

  func setupContainerStackView() {
    addSubview(containerStackView)
    containerStackView.axis = .vertical
    containerStackView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }

  func setupTextInputViewContainer() {
    containerStackView.addArrangedSubview(textInputViewContainer)
    switch textContainerType {
    case .outlinedSingleLine:
      textInputViewContainer.layer.cornerRadius = Constants.fieldCornerRadius
      textInputViewContainer.layer.borderWidth = Constants.fieldBorderWidth
      textInputViewContainer.layer.borderColor = Constants.inactiveStateBorderColor
      textInputViewContainer.snp.makeConstraints { make in
        make.trailing.leading.equalToSuperview()
        make.top.equalToSuperview().offset(7)
      }
    case .underscoredSingleLine:
      textInputViewContainer.snp.makeConstraints { make in
        make.trailing.leading.equalToSuperview()
        make.top.equalToSuperview()
      }
      underlineView?.backgroundColor = Constants.inactiveStateUnderlineColor
    }

    containerStackView.setCustomSpacing(4, after: textInputViewContainer)
  }

  func setupTitleLabel() {
    addSubview(titleLabel)
    titleLabel.change(textStyle: Constants.placeholderTextStyle)
    titleLabel.backgroundColor = .clear
    titleLabel.textColor = Constants.placeholderColor
    resetTitleConstraints()
  }

  func setupHintOrErrorLabel() {
    containerStackView.addArrangedSubview(hintOrErrorLabel)
    hintOrErrorLabel.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(16)
    }
    hintOrErrorLabel.textColor = Constants.hintColor
    hintOrErrorLabel.numberOfLines = 0
  }

  func updateTextEditAppearance() {
    guard textContainerType != .underscoredSingleLine else {
      return
    }
    if hasText {
      setToHasTextState()
    } else if !isEditing {
      resetTitleConstraints()
    }
  }

  func setupTextInputToolbar<ContainerFieldType: FieldType>(type: ContainerFieldType,
                                                            onDidTapNext: @escaping (() -> Void) = {},
                                                            onDidTapPrev: @escaping (() -> Void) = {},
                                                            onDidTapDone: @escaping (() -> Void) = {}) {
    let toolbar = DefaultKeyboardToolbar()
    toolbar.hasNextItem = !type.isLast
    toolbar.hasPreviousItem = !type.isFirst

    toolbar.onDidTapNext = onDidTapNext
    toolbar.onDidTapPrev = onDidTapPrev
    toolbar.onDidTapDone = onDidTapDone
    setInputAccessoryView(toolbar)
  }
    
  private func isErrorState(_ state: TextInputState) -> Bool {
    switch state {
    case .activeError, .inactiveError:
      return true
    default:
      return false
    }
  }
}

// MARK: - Configure

extension TextInput {
  func setup<T: FieldType>(with configurator: FieldConfigurator<T>) {
    delegate = configurator
    title = configurator.title
    returnKeyType = configurator.returnKeyType
    keyboardType = configurator.keyboardType
    textContentType = configurator.textContentType
    text = configurator.text
    if !text.isEmptyOrNil {
      setToHasTextState()
    }
    hintText = configurator.hint
    autocapitalizationType = configurator.autocapitalizationType
    shouldAnimateEditingStart = configurator.shouldAnimateEditingStart
    hasClearButton = configurator.hasClearButton
    isSecureTextEntry = configurator.isSecureTextEntry
    isHidden = configurator.isHidden
    if !configurator.isEnabled {
      setState(.disabled)
    }

    configurator.onDidEncounterValidationError = { [unowned self] errorText in
      self.setToErrorState(errorText: errorText)
    }
    configurator.onDidRequestResetToDefault = { [weak self] in
      self?.resetToDefaultState()
    }
    configurator.onDidRequestReturn = { [unowned self] _ in
      self.resignFirstResponder()
    }
    configurator.onChangeTextEditHiddenStateRequested = { [unowned self] isHidden in
      self.isHidden = isHidden
    }
    configurator.onChangeTextEditEnabledStateRequested = { [unowned self] isEnabled in
      self.setState(isEnabled ? .inactive : .disabled)
    }
    configurator.onNeedsToChangeText = { [unowned self] text in
      self.updateText(to: text)
    }
    
    handleEditingChanged()
    
    additionalSetup(with: configurator)
  }
  
  func additionalSetup<T: FieldType>(with configurator: FieldConfigurator<T>) {
    // do nothing by default
  }
}

// MARK: - Handle editing begin/end

extension TextInput {
  func handleEditingBeginning() {
    switch state {
    case .activeError(let errorText):
      setState(.activeError(errorText: errorText))
    case .inactiveError(let errorText):
      setState(.activeError(errorText: errorText))
    default:
      setState(.active)
    }
  }

  func handleShouldEndEditingState() {
    updateTitleStateForNoTextIfNeeded(animated: true)
    switch state {
    case .activeError(let errorText):
      setState(.inactiveError(errorText: errorText))
    case .inactiveError(let errorText):
      setState(.inactiveError(errorText: errorText))
    default:
      setState(.inactive)
    }
  }
}

// MARK: - Change state

extension TextInput {
  func setToHasTextState() {
    guard textContainerType != .underscoredSingleLine else {
      return
    }
    configurePlaceholderToTitleState()
    movePlaceholderToTitle()
  }

  func updateTitleStateForNoTextIfNeeded(animated: Bool = false) {
    guard textContainerType != .underscoredSingleLine, !hasText else {
      return
    }

    titleLabel.change(textStyle: Constants.placeholderTextStyle)
    titleLabel.textColor = Constants.placeholderColor
    textInputViewContainer.layer.mask = nil
    resetTitleConstraints()
    if animated {
      let animationDuration: TimeInterval = 0.2
      animateContainerMask(from: titleGapMaskPath(), to: noGapMaskPath(), duration: animationDuration)
      UIView.animate(withDuration: animationDuration, animations: {
        self.layoutIfNeeded()
      }, completion: nil)
    }
  }

  func configurePlaceholderToTitleState() {
    guard textContainerType != .underscoredSingleLine else {
      return
    }
    titleLabel.change(textStyle: Constants.titleTextStyle)
    titleLabel.sizeToFit()
  }

  func movePlaceholderToTitle(updateMask: Bool = true) {
    guard textContainerType != .underscoredSingleLine else {
      return
    }

    titleLabel.snp.remakeConstraints { make in
      make.centerY.equalTo(textInputViewContainer.snp.top)
      make.leading.equalToSuperview().offset(Constants.titleLeadingOffset)
    }
    titleState = .title

    if updateMask {

      if bounds.width == 0 || textInputViewContainer.bounds.width == 0 {
        shouldUpdateAppearance = true
      }
      
      let maskLayer = CAShapeLayer()
      let path = CGMutablePath()
      path.addRect(CGRect(x: Constants.titleLeadingOffset - Constants.titleLabelMaskInstes,
                          y: -textInputViewContainer.frame.minY,
                          width: titleLabel.frame.width + Constants.titleLabelMaskInstes * 2,
                          height: titleLabel.frame.height))
      path.addRect(textInputViewContainer.bounds)
      maskLayer.path = path
      maskLayer.fillRule = .evenOdd
      textInputViewContainer.layer.mask = maskLayer
    }
  }

  func setToErrorState(errorText: String?) {
    switch state {
    case .active:
      setState(.activeError(errorText: errorText))
    case .activeError:
      setState(.activeError(errorText: errorText))
    default:
      setState(.inactiveError(errorText: errorText))
    }
  }

  func resetToDefaultState() {
    if case .disabled = state {
      return
    }
    if isEditing {
      setState(.active)
    } else {
      setState(.inactive)
    }
  }

  func setState(_ state: TextInputState) {
    textInputViewContainer.backgroundColor = Constants.backgroundColor
    let titleLabelIsInTitleState = titleState == .title
    textInputView.textColor = Constants.defaultTextColor
    textInputView.isEnabled = true
    textInputViewContainer.isUserInteractionEnabled = true

    switch state {
    case .activeError(let errorText):
      handleErrorState(errorText: errorText, isActive: true)
    case .inactiveError(let errorText):
      handleErrorState(errorText: errorText, isActive: false)
    case .active:
      switch textContainerType {
      case .outlinedSingleLine:
        titleLabel.textColor = titleLabelIsInTitleState ? Constants.activeTitleTextColor : Constants.placeholderColor
        textInputViewContainer.layer.borderColor = Constants.activeStateBorderColor
      case .underscoredSingleLine:
        underlineView?.backgroundColor = Constants.activeStateUnderlineColor
      }
      handleNoErrorState()
    case .inactive, .disabled:
      switch textContainerType {
      case .outlinedSingleLine:
        titleLabel.textColor = titleLabelIsInTitleState ? Constants.defaultTitleTextColor : Constants.placeholderColor
        textInputViewContainer.layer.borderColor = Constants.inactiveStateBorderColor
      case .underscoredSingleLine:
        underlineView?.backgroundColor = Constants.inactiveStateUnderlineColor
      }

      if case .disabled = state {
        titleLabel.textColor = Constants.disabledTextColor
        textInputView.textColor = Constants.disabledTextColor
        textInputView.isEnabled = false
        textInputViewContainer.isUserInteractionEnabled = false
        movePlaceholderToTitle()
      }
 
      handleNoErrorState()
    }

    if hintOrErrorLabel.isHidden != hintOrErrorLabel.text.isEmptyOrNil {
      hintOrErrorLabel.snp.remakeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(16)
        make.height.equalTo(hintOrErrorLabel.height)
      }
    }
    
    hintOrErrorLabel.isHidden = hintOrErrorLabel.text.isEmptyOrNil
    
    self.state = state
  }

  private func handleErrorState(errorText: String?, isActive: Bool) {
    let titleLabelIsInTitleState = titleState == .title
    hintOrErrorLabel.text = errorText
    hintOrErrorLabel.isHidden = errorText.isEmptyOrNil
    hintOrErrorLabel.textColor = Constants.errorTextColor
    switch textContainerType {
    case .outlinedSingleLine:
      textInputViewContainer.layer.borderColor = Constants.errorStateBorderColor
      titleLabel.textColor = titleLabelIsInTitleState ? Constants.errorTextColor : Constants.placeholderColor
    case .underscoredSingleLine:
      underlineView?.backgroundColor = isActive ? Constants.activeStateUnderlineColor : Constants.inactiveStateUnderlineColor
      textInputView.textColor = Constants.errorTextColor
    }
    if !hasError {
      onChangedHintOrErrorHeight?()
    }
  }

  private func handleNoErrorState() {
    hintOrErrorLabel.text = storedHint
    hintOrErrorLabel.isHidden = storedHint.isEmptyOrNil
    hintOrErrorLabel.textColor = Constants.hintColor

    if hasError {
      onChangedHintOrErrorHeight?()
    }
  }
}

// MARK: - Start editing animation

extension TextInput {
  func startEditing() {
    guard !isEditing, textContainerType != .underscoredSingleLine else { return }

    guard !hasText, shouldAnimateEditingStart else {
      makeTextInputFirstResponder()
      return
    }
    
    isUserInteractionEnabled = false

    configurePlaceholderToTitleState()
    movePlaceholderToTitle(updateMask: false)

    let animationDuration: TimeInterval = 0.2

    animateContainerMask(from: noGapMaskPath(), to: titleGapMaskPath(), duration: animationDuration)

    UIView.animate(withDuration: animationDuration, animations: {
      self.layoutIfNeeded()
    }, completion: { _ in
      self.isUserInteractionEnabled = true
      guard self.shouldBecomeFirstResponder else {
        return
      }
      self.makeTextInputFirstResponder()
    })
  }

  private func animateContainerMask(from originalPath: CGPath, to finalPath: CGPath, duration: TimeInterval) {
    if bounds.width == 0 || textInputViewContainer.bounds.width == 0 {
      shouldUpdateAppearance = true
    }

    let animationKey = "maskPath"
    textInputViewContainer.layer.mask?.removeAnimation(forKey: animationKey)

    let maskLayer = CAShapeLayer()
    maskLayer.path = originalPath
    maskLayer.fillRule = .evenOdd
    textInputViewContainer.layer.mask = maskLayer

    let animation = CABasicAnimation(keyPath: "path")
    animation.fromValue = maskLayer.path
    animation.toValue = finalPath
    animation.duration = duration
    animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
    maskLayer.add(animation, forKey: animationKey)

    CATransaction.begin()
    CATransaction.setDisableActions(true)
    maskLayer.path = finalPath
    CATransaction.commit()
  }

  private func titleGapMaskPath() -> CGPath {
    let path = CGMutablePath()
    let gapWidth = titleLabel.frame.width + Constants.titleLabelMaskInstes * 2
    path.addRect(CGRect(x: Constants.titleLeadingOffset - Constants.titleLabelMaskInstes,
                        y: -textInputViewContainer.frame.minY,
                        width: gapWidth,
                        height: titleLabel.frame.height))
    path.addRect(textInputViewContainer.bounds)
    return path
  }

  private func noGapMaskPath() -> CGPath {
    let path = CGMutablePath()
    path.addRect(CGRect(x: Constants.titleLeadingOffset - Constants.titleLabelMaskInstes,
                        y: -textInputViewContainer.frame.minY,
                        width: 0.1,
                        height: titleLabel.frame.height))
    path.addRect(textInputViewContainer.bounds)
    return path
  }

  func setupAdditionalViews() {
    // do nothing by default
  }

  func configure(for state: TextInputState) {
    // do nothing by default
  }
}
