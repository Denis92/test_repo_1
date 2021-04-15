//
//  AgreementCheckboxView.swift
//  ForwardLeasing
//

import UIKit

protocol AgreementCheckboxViewModelProtocol: class {
  var isSelected: Bool { get }
  var agreement: NSAttributedString { get }
  var onDidToggleCheckbox: ((Bool) -> Void)? { get set }
  var onDidSelectURL: ((URL) -> Void)? { get set }
}

class AgreementCheckboxView: UIView, Configurable {
  // MARK: - Outlets
  private let checkbox = Checkbox(type: .rounded)
  private let agreementTextView = UITextView()
  
  // MARK: - Properties
  var onDidSelectURL: ((URL) -> Void)?
  var onDidToggleCheckbox: ((Bool) -> Void)?
  
  private let hasHorizontalInsets: Bool
  
  // MARK: - Init
  
  init(hasHorizontalInsets: Bool = true) {
    self.hasHorizontalInsets = hasHorizontalInsets
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    self.hasHorizontalInsets = true
    super.init(coder: coder)
    setup()
  }
  
  // MARK: - Public Methods
  
  func configure(with viewModel: AgreementCheckboxViewModelProtocol) {
    checkbox.isSelected = viewModel.isSelected
    agreementTextView.attributedText = viewModel.agreement
    onDidSelectURL = viewModel.onDidSelectURL
    onDidToggleCheckbox = viewModel.onDidToggleCheckbox
  }
  
  // MARK: - Private Methods
  
  private func setup() {
    setupCheckbox()
    setupAgreementTextView()
  }
  
  private func setupCheckbox() {
    addSubview(checkbox)
    checkbox.addTarget(self, action: #selector(didSelectCheckbox), for: .valueChanged)
    checkbox.snp.makeConstraints { make in
      make.leading.equalToSuperview().offset(hasHorizontalInsets ? 13 : -7)
      if !hasHorizontalInsets {
        make.width.equalTo(44)
      }
      make.top.equalToSuperview()
    }
  }
  
  private func setupAgreementTextView() {
    addSubview(agreementTextView)
    agreementTextView.linkTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.accent]
    agreementTextView.isScrollEnabled = false
    agreementTextView.sizeToFit()
    agreementTextView.delegate = self
    agreementTextView.showsHorizontalScrollIndicator = false
    agreementTextView.isEditable = false
    agreementTextView.isSelectable = true
    agreementTextView.snp.makeConstraints { make in
      make.leading.equalTo(checkbox.snp.trailing).offset(5)
      make.top.equalToSuperview()
      make.trailing.equalToSuperview().inset(hasHorizontalInsets ? 20 : 0)
      make.bottom.equalToSuperview()
    }
  }
}

// MARK: - Actions
private extension AgreementCheckboxView {
  @objc func didSelectCheckbox() {
    onDidToggleCheckbox?(checkbox.isSelected)
  }
}

// MARK: - UITextViewDelegate
extension AgreementCheckboxView: UITextViewDelegate {
  func textView(_ textView: UITextView, shouldInteractWith URL: URL,
                in characterRange: NSRange,
                interaction: UITextItemInteraction) -> Bool {
    onDidSelectURL?(URL)
    return false
  }
}
