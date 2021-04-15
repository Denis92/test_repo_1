//
//  AboutAppViewController.swift
//  ForwardLeasing
//

import UIKit

class AboutAppViewController: BaseViewController {
  // MARK: - Subviews
  private let appIcon = UIImageView()
  private let appVersionLabel = AttributedLabel(textStyle: .textRegular)
  private let appDescriptionLabel = AttributedLabel(textStyle: .textRegular)
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  // MARK: - Private Methods
  private func setup() {
    setupAppIcon()
    setupAppVersionLabel()
    setupDescriptionLabel()
  }
  
  private func setupAppIcon() {
    view.addSubview(appIcon)
    appIcon.contentMode = .scaleAspectFit
    appIcon.image = R.image.logo()
    appIcon.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(32)
      make.leading.equalToSuperview().inset(16)
    }
  }
  
  private func setupAppVersionLabel() {
    view.addSubview(appVersionLabel)
    appVersionLabel.textColor = .base1
    appVersionLabel.text = R.string.profileSettings.aboutAppVersionText(Constants.fullAppVersion)
    appVersionLabel.snp.makeConstraints { make in
      make.top.equalTo(appIcon.snp.bottom).offset(24)
      make.leading.trailing.equalToSuperview().inset(16)
    }
  }
  
  private func setupDescriptionLabel() {
    view.addSubview(appDescriptionLabel)
    appDescriptionLabel.textColor = .base1
    appDescriptionLabel.numberOfLines = 0
    appDescriptionLabel.text = R.string.profileSettings.aboutAppDescriptionText()
    appDescriptionLabel.snp.makeConstraints { make in
      make.top.equalTo(appVersionLabel.snp.bottom).offset(16)
      make.leading.equalToSuperview().inset(16)
      make.trailing.equalToSuperview().inset(24)
    }
  }
}
