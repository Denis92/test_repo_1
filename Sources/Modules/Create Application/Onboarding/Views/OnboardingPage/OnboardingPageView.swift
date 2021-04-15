//
//  OnboardingPageView.swift
//  ForwardLeasing
//

import UIKit

class OnboardingPageView: UIView, Configurable {
  private var viewModel: OnboardingPageViewModel?
  
  // MARK: - Subviews
  private var titleLabel = AttributedLabel(textStyle: .title1Bold)
  private var pageNumberImageView = UIImageView()
  
  // MARK: - Init
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure
  func configure(with viewModel: OnboardingPageViewModel) {
    self.viewModel = viewModel
    self.titleLabel.text = viewModel.title
    self.pageNumberImageView.image = viewModel.pageNumberImage
  }
  
  // MARK: - Setup
  private func setup() {
    backgroundColor = .accent2
    setupTitleLabel()
    setupPageNumberImageView()
  }
  
  private func setupTitleLabel() {
    addSubview(titleLabel)
    titleLabel.numberOfLines = 0
    titleLabel.textColor = .base2
    titleLabel.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }
  
  private func setupPageNumberImageView() {
    addSubview(pageNumberImageView)
    pageNumberImageView.contentMode = .scaleAspectFit
    pageNumberImageView.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(54 + UIApplication.shared.statusBarFrame.height)
      make.leading.equalToSuperview().offset(20)
      make.bottom.lessThanOrEqualTo(titleLabel.snp.top).offset(-70)
    }
  }
}
