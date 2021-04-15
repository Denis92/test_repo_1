//
//  ProductLinkView.swift
//  ForwardLeasing
//

import UIKit

class ProductLinkView: UIView {
  // MARK: - Properties
  
  private let titleLabel = AttributedLabel(textStyle: .title2Bold)
  private let iconImageView = UIImageView()
  private let dividerView = UIView()
  
  private var viewModel: ProductLinkViewModel?
  
  // MARK: - Init
  
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure
  
  func configure(with viewModel: ProductLinkViewModel) {
    self.viewModel = viewModel
    titleLabel.text = viewModel.title
  }
  
  // MARK: - Actions
  
  @objc private func didTapView() {
    viewModel?.didTapView()
  }
  
  // MARK: - Setup
  
  private func setup() {
    setupTitleLabel()
    setupIconImageView()
    setupDividerView()
    
    addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapView)))
  }
  
  private func setupTitleLabel() {
    addSubview(titleLabel)
    titleLabel.numberOfLines = 0
    titleLabel.textColor = .base1
    titleLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(20)
      make.top.bottom.equalToSuperview().inset(20)
    }
  }
  
  private func setupIconImageView() {
    addSubview(iconImageView)
    iconImageView.image = R.image.disclosureIndicatorIcon()
    iconImageView.contentMode = .scaleAspectFit
    iconImageView.snp.makeConstraints { make in
      make.size.equalTo(24)
      make.leading.equalTo(titleLabel.snp.trailing).offset(12)
      make.centerY.equalToSuperview()
      make.trailing.equalToSuperview().inset(20)
    }
  }
  
  private func setupDividerView() {
    addSubview(dividerView)
    dividerView.backgroundColor = .shade30
    dividerView.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.leading.trailing.equalToSuperview().inset(20)
      make.height.equalTo(1)
    }
  }
}
