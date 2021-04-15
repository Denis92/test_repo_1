//
//  DocumentPDFView.swift
//  ForwardLeasing
//

import UIKit

enum DocumentPDFViewType {
  case contract, agreement, newLeasingContract
  
  var title: String? {
    switch self {
    case .contract:
      return R.string.contractSigning.contractPdfTitle()
    case .agreement:
      return R.string.contractSigning.agreementPdfTitle()
    case .newLeasingContract:
      return R.string.contractSigning.newLeasingContractPdfTitle()
    }
  }
}

enum DocumentPDFViewSigningState {
  case signed, notSigned
  
  func getSignedStateTitle(type: DocumentPDFViewType) -> String {
    switch (self, type) {
    case (.signed, .contract), (.signed, .newLeasingContract):
      return R.string.contractSigning.contractSignedStateTitle()
    case (.notSigned, .contract), (.notSigned, .newLeasingContract):
      return R.string.contractSigning.contractNotSignedStateTitle()
    case (.signed, .agreement):
      return R.string.contractSigning.agreementSignedStateTitle()
    case (.notSigned, .agreement):
      return R.string.contractSigning.agreementNotSignedStateTitle()
    }
  }
  
  var color: UIColor {
    switch self {
    case .signed:
      return .access
    case .notSigned:
      return .shade70
    }
  }
}

protocol DocumentPDFViewModelProtocol {
  var type: DocumentPDFViewType { get }
  var signingState: DocumentPDFViewSigningState { get }
  func didTapButton()
}

typealias DocumentPDFCell = CommonContainerTableViewCell<DocumentPDFView>

class DocumentPDFView: UIView, Configurable {
  // MARK: - Properties
  
  var signingState: DocumentPDFViewSigningState = .notSigned {
    didSet {
      updateSigningState()
    }
  }
  
  var onDidTapButton: (() -> Void)?
  
  private let pdfButton = UIButton(type: .system)
  private let contentStackView = UIStackView()
  private let titleLabel = AttributedLabel(textStyle: .title3Regular)
  private let subtitle = AttributedLabel(textStyle: .footnoteRegular)
  
  private var viewModel: DocumentPDFViewModelProtocol?
  
  // MARK: - Init
  
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure
  
  func configure(type: DocumentPDFViewType, signingState: DocumentPDFViewSigningState) {
    titleLabel.text = type.title
    subtitle.text = signingState.getSignedStateTitle(type: type)
    self.signingState = signingState
  }
  
  func configure(with viewModel: DocumentPDFViewModelProtocol) {
    self.viewModel = viewModel
    configure(type: viewModel.type, signingState: viewModel.signingState)
  }
  
  // MARK: - Actions
  
  @objc private func didTapButton() {
    onDidTapButton?()
    viewModel?.didTapButton()
  }
  
  // MARK: - Setup
  
  private func setup() {
    setupContainer()
    setupPdfButton()
    setupContentStackView()
    setupTitleLabel()
    setupSubtitleLabel()
  }
  
  private func setupContainer() {
    snp.makeConstraints { make in
      make.height.equalTo(64)
    }
  }
  
  private func setupPdfButton() {
    addSubview(pdfButton)
    
    pdfButton.layer.borderWidth = 2
    pdfButton.layer.borderColor = UIColor.accent.cgColor
    pdfButton.layer.cornerRadius = 8
    pdfButton.titleLabel?.font = .title3Semibold
    pdfButton.tintColor = .accent
    pdfButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 16)
    pdfButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6)
    pdfButton.setTitleColor(.accent, for: .normal)
    pdfButton.setContentHuggingPriority(.required, for: .horizontal)
    pdfButton.setImage(R.image.docIcon(), for: .normal)
    pdfButton.setTitle(R.string.contractSigning.pdfButtonTitle(), for: .normal)
    pdfButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    
    pdfButton.snp.makeConstraints { make in
      make.leading.equalToSuperview()
      make.centerY.equalToSuperview()
    }
  }
  
  private func setupContentStackView() {
    addSubview(contentStackView)
    contentStackView.axis = .vertical
    contentStackView.snp.makeConstraints { make in
      make.leading.equalTo(pdfButton.snp.trailing).offset(16)
      make.trailing.equalToSuperview()
      make.centerY.equalToSuperview()
    }
  }
  
  private func setupTitleLabel() {
    contentStackView.addArrangedSubview(titleLabel)
    titleLabel.textColor = .base1
  }
  
  private func setupSubtitleLabel() {
    contentStackView.addArrangedSubview(subtitle)
    updateSigningState()
  }
  
  private func updateSigningState() {
    if let type = viewModel?.type {
      subtitle.text = signingState.getSignedStateTitle(type: type)
    }
    subtitle.textColor = signingState.color
  }
}
