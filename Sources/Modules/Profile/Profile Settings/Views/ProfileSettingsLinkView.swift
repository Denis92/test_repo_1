//
//  ProfileSettingsLinkView.swift
//  ForwardLeasing
//

import UIKit

protocol ProfileSettingsLinkViewModelProtocol {
  var title: String? { get }
}

typealias ProfileSettingsLinkCell = CommonContainerTableViewCell<ProfileSettingsLinkView>

class ProfileSettingsLinkView: UIView, Configurable {
  // MARK: - Subviews
  private let titleLabel = AttributedLabel(textStyle: .title3Regular)
  private let arrowIcon = UIImageView()
  
  // MARK: - Properties
  
  // MARK: - Init
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }
  
  // MARK: - Public Methods
  func configure(with viewModel: ProfileSettingsLinkViewModelProtocol) {
    titleLabel.text = viewModel.title
  }
  
  // MARK: - Private Methods
  private func setup() {
    setupTitleLabel()
    setupArrowIcon()
  }
  
  private func setupTitleLabel() {
    addSubview(titleLabel)
    titleLabel.textColor = .base1
    titleLabel.numberOfLines = 0
    titleLabel.snp.makeConstraints { make in
      make.top.bottom.equalToSuperview().inset(11)
      make.leading.equalToSuperview().inset(20)
    }
  }
  
  private func setupArrowIcon() {
    addSubview(arrowIcon)
    arrowIcon.contentMode = .scaleAspectFit
    arrowIcon.image = R.image.disclosureIndicatorIcon()
    arrowIcon.snp.makeConstraints { make in
      make.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(16)
      make.centerY.equalToSuperview()
      make.trailing.equalToSuperview().inset(16)
    }
  }
}
