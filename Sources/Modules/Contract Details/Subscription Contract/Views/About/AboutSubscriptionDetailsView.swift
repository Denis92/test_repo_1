//
//  AboutSubscriptionDetailsView.swift
//  ForwardLeasing
//

import UIKit

protocol AboutSubscriptionDetailsViewModelProtocol {
  var text: String? { get }
}

class AboutSubscriptionDetailsView: UIView, Configurable {
  private let titleLabel = AttributedLabel(textStyle: .title2Bold)
  private let textLabel = AttributedLabel(textStyle: .textRegular)

  // MARK: - Init
  init() {
    super.init(frame: .zero)
    setup()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }

  // MARK: - Configure

  func configure(with viewModel: AboutSubscriptionDetailsViewModelProtocol) {
    textLabel.text = viewModel.text
  }

  // MARK: - Setup
  private func setup() {
    addTitleLabel()
    addTextLabel()
  }

  private func addTitleLabel() {
    addSubview(titleLabel)
    titleLabel.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.top.equalToSuperview().offset(8)
    }
    titleLabel.text = R.string.subscriptionDetails.aboutSubscriptionSectionTitle()
  }

  private func addTextLabel() {
    addSubview(textLabel)
    textLabel.snp.makeConstraints { make in
      make.leading.trailing.bottom.equalToSuperview()
      make.top.equalTo(titleLabel.snp.bottom).offset(12)
    }
  }
}
