//
//  ClosedContractItemView.swift
//  ForwardLeasing
//

import UIKit

class ClosedContractItemView: UIView {
  // MARK: - Properties
  
  var onDidTapView: (() -> Void)?
  
  var hidesDivider: Bool = false {
    didSet {
      dividerView.isHidden = hidesDivider
    }
  }
  
  private let containerStackView = UIStackView()
  private let contentStackView = UIStackView()
  private let titleLabel = AttributedLabel(textStyle: .textBold)
  private let priceLabel = AttributedLabel(textStyle: .title2Bold)
  private let dateLabel = AttributedLabel(textStyle: .textRegular)
  private let imageView = UIImageView()
  private let dividerView = UIView()
  
  // MARK: - Init
  
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure
  
  func configure(leasingEntity: LeasingEntity) {
    titleLabel.text = leasingEntity.productInfo.goodName
    priceLabel.text = leasingEntity.productInfo.monthPay?.priceString()
    
    if let date = leasingEntity.contractInfo?.paymentSchedule.last?.paymentDate {
      dateLabel.text = R.string.profile.closedContractDate(DateFormatter.dayMonthYearDisplayable.string(from: date))
    } else {
      dateLabel.text = nil
    }
    
    if let imageString = leasingEntity.productImage {
      imageView.setImage(with: URL(string: imageString))
    }
  }
  
  // MARK: - Actions
  
  @objc private func didTapView() {
    onDidTapView?()
  }
  
  // MARK: - Setup
  
  private func setup() {
    setupContainerStackView()
    setupContentStackView()
    setupTitleLabel()
    setupPriceLabel()
    setupDateLabel()
    setupImageView()
    setupDividerView()
    
    addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapView)))
  }
  
  private func setupContainerStackView() {
    addSubview(containerStackView)
    containerStackView.axis = .horizontal
    containerStackView.spacing = 16
    containerStackView.alignment = .center
    containerStackView.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview().inset(20)
      make.bottom.equalToSuperview().inset(16)
    }
  }
  
  private func setupContentStackView() {
    containerStackView.addArrangedSubview(contentStackView)
    contentStackView.axis = .vertical
    contentStackView.spacing = 10
  }
  
  private func setupTitleLabel() {
    contentStackView.addArrangedSubview(titleLabel)
    titleLabel.numberOfLines = 0
  }
  
  private func setupPriceLabel() {
    contentStackView.addArrangedSubview(priceLabel)
    priceLabel.numberOfLines = 0
  }
  
  private func setupDateLabel() {
    contentStackView.addArrangedSubview(dateLabel)
    dateLabel.numberOfLines = 0
    dateLabel.textColor = .shade70
  }
  
  private func setupImageView() {
    containerStackView.addArrangedSubview(imageView)
    imageView.contentMode = .scaleAspectFit
    imageView.snp.makeConstraints { make in
      make.size.equalTo(122)
    }
  }
  
  private func setupDividerView() {
    addSubview(dividerView)
    dividerView.backgroundColor = .shade40
    dividerView.snp.makeConstraints { make in
      make.bottom.equalToSuperview()
      make.leading.trailing.equalToSuperview().inset(20)
      make.height.equalTo(0.5)
    }
  }
}
