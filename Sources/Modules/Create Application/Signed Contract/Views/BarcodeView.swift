//
//  BarcodeView.swift
//  ForwardLeasing
//

import UIKit

private extension Constants {
  static let gradientStartColor = UIColor(red: 0.938, green: 0.328, blue: 0.621, alpha: 1)
  static let gradientEndColor = UIColor(red: 1, green: 0.404, blue: 0.196, alpha: 1)
  static let gradientStartPosition = CGPoint(x: 0, y: 0)
  static let gradientEndPosition = CGPoint(x: 1, y: 1)
}

protocol BarcodeViewModelProtocol {
  var contractNumber: String? { get }
  var title: String? { get }
  var contentStrings: [String] { get }
  var additionalInfo: [String] { get }
}

typealias BarcodeCell = CommonContainerTableViewCell<BarcodeView>

class BarcodeView: UIStackView, Configurable {
  // MARK: - Properties
  
  private let gradientLayer = CAGradientLayer()
  private let contentView = UIView()
  private let barcodeContainerView = UIView()
  private let contentStackView = UIStackView()
  private let titleLabel = AttributedLabel(textStyle: .title3Semibold)
  private let imageView = UIImageView()
  private let barcodeNumberLabel = AttributedLabel(textStyle: .title2Semibold)
  
  // MARK: - Init
  
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Overrides
  
  override func layoutSubviews() {
    super.layoutSubviews()
    gradientLayer.frame = contentView.bounds
  }
  
  // MARK: - Configure
  
  func configure(contractNumber: String?, title: String?,
                 contentStrings: [String] = [], additionalInfo: [String] = []) {
    guard let contractNumber = contractNumber, let barcodeImage = UIImage.makeBarcode(from: contractNumber) else { return }
    imageView.image = barcodeImage
    barcodeNumberLabel.text = contractNumber
    imageView.snp.makeConstraints { make in
      make.height.equalTo(imageView.snp.width).multipliedBy(barcodeImage.size.height / barcodeImage.size.width)
    }
    
    titleLabel.text = title
    setupAdditionalInfo(additionalInfoStrings: additionalInfo)
    setupContent(contentStrings: contentStrings)
  }
  
  func configure(with viewModel: BarcodeViewModelProtocol) {
    configure(contractNumber: viewModel.contractNumber, title: viewModel.title,
              contentStrings: viewModel.contentStrings, additionalInfo: viewModel.additionalInfo)
  }
  
  // MARK: - Setup
  
  private func setup() {
    axis = .vertical
    setupContentView()
    setupContentStackView()
    setupTitleLabel()
    setupBarcodeContainerView()
    setupImageView()
    setupBarcodeNumberLabel()
  }
  
  private func setupContentView() {
    addArrangedSubview(contentView)
    contentView.layer.cornerRadius = 10
    contentView.clipsToBounds = true
    
    gradientLayer.colors = [Constants.gradientStartColor.cgColor, Constants.gradientEndColor.cgColor]
    gradientLayer.startPoint = Constants.gradientStartPosition
    gradientLayer.endPoint = Constants.gradientEndPosition
    contentView.layer.addSublayer(gradientLayer)
    
    setCustomSpacing(12, after: contentView)
  }
  
  private func setupContentStackView() {
    contentView.addSubview(contentStackView)
    contentStackView.axis = .vertical
    contentStackView.spacing = 10
    contentStackView.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(24)
      make.leading.trailing.equalToSuperview().inset(12)
    }
  }
  
  private func setupTitleLabel() {
    contentStackView.addArrangedSubview(titleLabel)
    titleLabel.textColor = .base2
    titleLabel.numberOfLines = 0
    titleLabel.textAlignment = .center
    contentStackView.setCustomSpacing(24, after: titleLabel)
  }
  
  private func setupBarcodeContainerView() {
    contentView.addSubview(barcodeContainerView)
    barcodeContainerView.backgroundColor = .base2
    barcodeContainerView.layer.cornerRadius = 10
    barcodeContainerView.snp.makeConstraints { make in
      make.top.equalTo(contentStackView.snp.bottom).offset(24)
      make.leading.trailing.bottom.equalToSuperview().inset(12)
    }
  }
  
  private func setupImageView() {
    barcodeContainerView.addSubview(imageView)
    imageView.contentMode = .scaleAspectFit
    imageView.setContentHuggingPriority(.required, for: .vertical)
    imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    imageView.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview().inset(12)
    }
  }
  
  private func setupBarcodeNumberLabel() {
    barcodeContainerView.addSubview(barcodeNumberLabel)
    barcodeNumberLabel.textAlignment = .center
    barcodeNumberLabel.snp.makeConstraints { make in
      make.top.equalTo(imageView.snp.bottom).offset(8)
      make.leading.trailing.bottom.equalToSuperview().inset(12)
    }
  }
  
  private func setupContent(contentStrings: [String]) {
    contentStackView.arrangedSubviews.forEach { subview in
      if subview != titleLabel {
        subview.removeFromSuperview()
      }
    }
    
    contentStrings.forEach { string in
      let label = AttributedLabel(textStyle: .footnoteRegular)
      label.textColor = .base2
      label.numberOfLines = 0
      label.text = string
      contentStackView.addArrangedSubview(label)
    }
  }
  
  private func setupAdditionalInfo(additionalInfoStrings: [String]) {
    arrangedSubviews.forEach { subview in
      if subview != contentView {
        subview.removeFromSuperview()
      }
    }
    
    additionalInfoStrings.forEach { string in
      let label = AttributedLabel(textStyle: .textRegular)
      label.numberOfLines = 0
      label.text = string
      addArrangedSubview(label)
      setCustomSpacing(16, after: label)
    }
  }
}
