//
//  OutlinedSingleLineTextInput.swift
//  ForwardLeasing
//

import UIKit

private extension Constants {
  static let clearButtonTintColor: UIColor = .shade70
  static let height: CGFloat = 56
  static let titleLeadingOffset: CGFloat = 16
  static let titleLabelMaskInstes: CGFloat = 4
  static let fieldCornerRadius: CGFloat = 8
  static let fieldBorderWidth: CGFloat = 1.5
}

class OutlinedSingleLineTextInput: UIView, TextInput {
  // MARK: - Properties
  var storedErrorText: String?
  var storedHint: String?
  var state: TextInputState = .inactive
  var titleState: TitleState = .title
  var shouldAnimateEditingStart = true
  var shouldBecomeFirstResponder = false
  var shouldUpdateAppearance = false
  var isSecureTextEntry = false
  var maskLayer: CAShapeLayer?

  weak var delegate: TextInputDelegate?

  var onChangedHintOrErrorHeight: (() -> Void)?

  var textContainerType: TextContainerType {
    return .outlinedSingleLine
  }

  var text: String? {
    get { return textField.text }
    set {
      textField.text = newValue
      if !isEditing, !newValue.isEmptyOrNil {
        textField.isUserInteractionEnabled = true
      } else if !isEditing, newValue.isEmptyOrNil {
        textField.isUserInteractionEnabled = false
      }
      handleEditingChanged()

      guard !isEditing else {
        return
      }
      if let datePicker = datePicker, let dateFormatter = dateFormatter,
        let dateString = newValue, let date = dateFormatter.date(from: dateString) {
        datePicker.date = date
      }
    }
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

  var rightView: UIView? {
    get { return textField.rightView }
    set { textField.rightView = newValue }
  }

  var rightViewMode: UITextField.ViewMode {
    get { return textField.rightViewMode }
    set {
      if textField.rightViewMode != newValue {
        textField.rightViewMode = newValue
      }
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

  var hasClearButton: Bool = false {
    didSet {
      configureRightView()
      handleEditingChanged()
    }
  }

  override var isFirstResponder: Bool {
    return textField.isFirstResponder
  }

  private let dateFormatter: DateFormatter?

  private var lastUpdatedRightViewLayoutFrame: CGRect = .zero

  // MARK: - Subviews

  var underlineView: UIView? {
    return nil
  }

  var textInputView: TextInputView {
    return textField
  }

  let containerStackView = UIStackView()
  let titleLabel = AttributedLabel(textStyle: .textRegular)
  let hintOrErrorLabel = AttributedLabel(textStyle: .footnoteRegular)
  let textInputViewContainer = UIView()

  private var pickerOptions: [String] = []
  private var tapGesture: UITapGestureRecognizer?

  private let datePicker: UIDatePicker?
  private let picker: UIPickerView?
  private let textField: SingleLineTextInputTextField
  private let clearButton = UIButton()

  // MARK: - Init

  init(inputType: TextInputType = .keyboard) {
    switch inputType {
    case .datePicker(let mode, let minDate, let maxDate, let dateFormatter):
      datePicker = UIDatePicker()
      if #available(iOS 13.4, *) {
        datePicker?.preferredDatePickerStyle = .wheels
      }
      datePicker?.datePickerMode = mode
      datePicker?.backgroundColor = .white
      datePicker?.minimumDate = minDate
      datePicker?.maximumDate = maxDate
      datePicker?.locale = Constants.appLocale
      textField = SingleLineTextInputTextField(shouldHideCaret: true)
      textField.inputView = datePicker
      self.dateFormatter = dateFormatter
      picker = nil
    case .keyboard:
      datePicker = nil
      picker = nil
      textField = SingleLineTextInputTextField()
      dateFormatter = nil
    case .picker:
      datePicker = nil
      dateFormatter = nil
      textField = SingleLineTextInputTextField(shouldHideCaret: true)
      picker = UIPickerView()
      textField.inputView = picker
    }
    textField.tintColor = .accent
    textField.isUserInteractionEnabled = false
    
    super.init(frame: .zero)

    picker?.dataSource = self
    picker?.delegate = self
    datePicker?.addTarget(self, action: #selector(handleDatePickerValueChanged(_:)), for: .valueChanged)
    setup()

    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(startTextFieldEditing))
    tapGesture.delegate = self
    self.tapGesture = tapGesture
    addGestureRecognizer(tapGesture)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Override
  @discardableResult
  override func becomeFirstResponder() -> Bool {
    shouldBecomeFirstResponder = true
    startEditing()
    return true
  }

  @discardableResult
  override func resignFirstResponder() -> Bool {
    shouldBecomeFirstResponder = false
    return textField.resignFirstResponder()
  }
  
  // MARK: - Lifecycle
  
  override func layoutSubviews() {
    super.layoutSubviews()
    if lastUpdatedRightViewLayoutFrame != bounds {
      configureRightView()
      lastUpdatedRightViewLayoutFrame = bounds
    }
    if shouldUpdateAppearance, bounds.width > 0 {
      containerStackView.layoutIfNeeded()
      textInputViewContainer.layoutIfNeeded()
      shouldUpdateAppearance = false
      updateTextEditAppearance()
    }
    textInputViewContainer.layer.mask?.frame = textInputViewContainer.bounds
  }
  
  // MARK: - Setup

  func setInputAccessoryView(_ view: UIView?) {
    textField.inputAccessoryView = view
  }

  func configure(for state: TextInputState) {
    switch state {
    case .activeError, .inactiveError:
      clearButton.tintColor = .error
    default:
      clearButton.tintColor = Constants.clearButtonTintColor
    }
    handleEditingChanged()
  }
  
  func additionalSetup<T: FieldType>(with configurator: FieldConfigurator<T>) {
    pickerOptions = configurator.pickerOptions
  }
  
  // MARK: - Add Subviews

  func setupTextEdit() {
    textInputViewContainer.addSubview(textField)
    textField.delegate = self
    textField.addTarget(self, action: #selector(handleEditingChanged), for: .editingChanged)
    textField.snp.makeConstraints { make in
      make.height.equalTo(Constants.height)
      make.edges.equalToSuperview()
    }
  }

  func setupAdditionalViews() {
    setupClearButton()
  }

  private func setupClearButton() {
    clearButton.setImage(R.image.clearButtonIcon()?.withRenderingMode(.alwaysTemplate), for: .normal)
    clearButton.imageView?.contentMode = .center
    clearButton.tintColor = Constants.clearButtonTintColor
    clearButton.addTarget(self, action: #selector(clear), for: .touchUpInside)
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

extension OutlinedSingleLineTextInput {
  @objc func handleDatePickerValueChanged(_ sender: UIDatePicker) {
    updateText(to: dateFormatter?.string(from: sender.date))
    delegate?.textInputEditingChanged(self)
  }

  @objc func handleEditingChanged() {
    delegate?.textInputEditingChanged(self)

    UIView.performWithoutAnimation {
      self.textField.rightView?.frame = self.textField.rightViewRect(forBounds: textField.bounds)
      self.textField.rightView?.layoutIfNeeded()
    }

    guard hasClearButton else { return }

    if textField.text.isEmptyOrNil {
      rightViewMode = .never
    } else {
      rightViewMode = .whileEditing
    }
  }

  @objc private func startTextFieldEditing() {
    shouldBecomeFirstResponder = true
    startEditing()
  }

  @objc private func clear() {
    textField.text = nil
    if !textField.isEditing {
      updateTitleStateForNoTextIfNeeded(animated: true)
      textField.isUserInteractionEnabled = false
    }
    handleEditingChanged()
    delegate?.textInputDidClearText(self)
  }
}

// MARK: - Right View

extension OutlinedSingleLineTextInput {
  private func configureRightView() {
    if hasClearButton {
      let containerView = UIView()
      containerView.addSubview(clearButton)
      clearButton.snp.makeConstraints { make in
        make.width.height.equalTo(24)
        make.edges.equalToSuperview().inset(16)
      }
      textField.rightView = containerView
    } else {
      textField.rightView = nil
    }

    UIView.performWithoutAnimation {
      self.textField.layoutIfNeeded()
      self.textField.rightView = rightView
      self.textField.rightView?.frame = textField.rightViewRect(forBounds: textField.bounds)
    }
  }
}

// MARK: - Public Methods

extension OutlinedSingleLineTextInput {
  func resetTitleConstraints() {
    guard titleState != .placeholder else {
      return
    }
    titleLabel.snp.remakeConstraints { make in
      make.trailing.leading.equalTo(textInputViewContainer).inset(16)
      make.centerY.equalTo(textInputViewContainer)
    }
    titleState = .placeholder
  }

  func makeTextInputFirstResponder() {
    textField.isUserInteractionEnabled = true
    textField.becomeFirstResponder()
  }
}

// MARK: - UIGestureRecognizerDelegate

extension OutlinedSingleLineTextInput: UIGestureRecognizerDelegate {
  override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    guard textField.isEnabled else {
      return false
    }
    guard gestureRecognizer == tapGesture, !text.isEmptyOrNil else {
      return true
    }
    let location = gestureRecognizer.location(in: self)
    let frame = textInputViewContainer.convert(textField.frame, to: self)
    guard !frame.contains(location), !isEditing else {
      return false
    }
    return true
  }
}

// MARK: - UITextFieldDelegate

extension OutlinedSingleLineTextInput: UITextFieldDelegate {
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    guard textField.isEnabled else {
      return false
    }
    let shouldBegin = delegate?.textInputShouldBeginEditing(self) ?? true
    if shouldBegin {
      handleEditingBeginning()
    }
    return shouldBegin
  }

  func textFieldDidBeginEditing(_ textField: UITextField) {
    if textField.text.isEmptyOrNil, let datePicker = datePicker {
      handleDatePickerValueChanged(datePicker)
    }
    if textField.text.isEmptyOrNil, let index = picker?.selectedRow(inComponent: 0) {
      updateText(to: pickerOptions.element(at: index))
      delegate?.textInputEditingChanged(self)
    }
    handleEditingChanged()
    delegate?.textInputDidBeginEditing(self)
  }

  func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
    let shouldEnd = delegate?.textInputShouldEndEditing(self) ?? true
    if shouldEnd {
      shouldBecomeFirstResponder = false
      handleShouldEndEditingState()
    }
    return shouldEnd
  }

  func textFieldDidEndEditing(_ textField: UITextField) {
    textField.isUserInteractionEnabled = !textField.text.isEmptyOrNil
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

extension OutlinedSingleLineTextInput: UIPickerViewDataSource {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }

  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return pickerOptions.count
  }
}

extension OutlinedSingleLineTextInput: UIPickerViewDelegate {
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return pickerOptions.element(at: row)
  }

  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    updateText(to: pickerOptions.element(at: row))
    delegate?.textInputEditingChanged(self)
  }
}
