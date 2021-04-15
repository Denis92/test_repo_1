//
//  RenewSubscriptionDetailsView.swift
//  ForwardLeasing
//

import UIKit

protocol RenewSubscriptionDetailsViewModelProtocol: class {
  var cardText: String? { get }
  var renewButtonTitle: String? { get }
  var onDidUpdateCardText: ((String?) -> Void)? { get set }

  func renewScubscription()
  func changeCard()
}

class RenewSubscriptionDetailsView: UIView, Configurable {
  private let titleLabel = AttributedLabel(textStyle: .title2Bold)
  private let cardView = UIView()
  private let cardLabel = AttributedLabel(textStyle: .title2Regular)
  private let renewButton = StandardButton(type: .primary)

  private var didTapRenewButton: (() -> Void)?
  private var didTapCardInfo: (() -> Void)?

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

  func configure(with viewModel: RenewSubscriptionDetailsViewModelProtocol) {
    cardLabel.text = viewModel.cardText
    renewButton.setTitle(viewModel.renewButtonTitle, for: .normal)
    viewModel.onDidUpdateCardText = { [weak self] cardText in
      self?.cardLabel.text = cardText
    }
    didTapCardInfo = { [weak viewModel] in
      viewModel?.changeCard()
    }
    didTapRenewButton = { [weak viewModel] in
      viewModel?.renewScubscription()
    }
  }

  // MARK: - Setup
  private func setup() {
    addTitleLabel()
    addCardView()
    addCardLabel()
    addRenewButton()
  }

  private func addTitleLabel() {
    addSubview(titleLabel)
    titleLabel.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.top.equalToSuperview().offset(40)
    }
    titleLabel.text = R.string.subscriptionDetails.renewSubscriptionSectionTitle()
  }

  private func addCardView() {
    addSubview(cardView)
    let height: CGFloat = 68
    cardView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.height.equalTo(height)
      make.top.equalTo(titleLabel.snp.bottom).offset(16)
    }
    cardView.makeRoundedCorners(radius: height * 0.5)
    cardView.layer.borderColor = UIColor.shade60.cgColor
    cardView.layer.borderWidth = 0.5

    cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleCardViewTapped(_:))))
  }

  private func addCardLabel() {
    cardView.addSubview(cardLabel)
    cardLabel.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(28)
      make.centerY.equalToSuperview()
    }
  }

  private func addRenewButton() {
    addSubview(renewButton)
    renewButton.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.top.equalTo(cardView.snp.bottom).offset(40)
      make.bottom.equalToSuperview().inset(48)
    }
    renewButton.addTarget(self, action: #selector(handleRenewButtonTapped(_:)), for: .touchUpInside)
  }

  // MARK: - Actions

  @objc private func handleRenewButtonTapped(_ sender: UIButton) {
    didTapRenewButton?()
  }

  @objc private func handleCardViewTapped(_ sender: UITapGestureRecognizer) {
    didTapCardInfo?()
  }
}

