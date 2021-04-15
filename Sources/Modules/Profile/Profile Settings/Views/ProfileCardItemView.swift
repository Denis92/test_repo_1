//
//  ProfileCardItemView.swift
//  ForwardLeasing
//

import UIKit

protocol ProfileCardItemViewModelProtocol: class {
  var cardNumber: String? { get }
  var onDidFinishDelete: (() -> Void)? { get set }
  func delete()
}

typealias ProfileCardCell = CommonContainerTableViewCell<ProfileCardItemView>

class ProfileCardItemView: UIView, Configurable {
  // MARK: - Subviews
  private let cardNumberLabel = AttributedLabel(textStyle: .title3Regular)
  private let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
  private let deleteButton = UIButton()
  private let separator = UIView()
  
  // MARK: - Properties
  override var intrinsicContentSize: CGSize {
    return CGSize(width: UIView.noIntrinsicMetric, height: 64)
  }
  
  private var onDidTapDelete: (() -> Void)?
  
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
  func configure(with viewModel: ProfileCardItemViewModelProtocol) {
    cardNumberLabel.text = viewModel.cardNumber
    viewModel.onDidFinishDelete = { [weak self] in
      self?.setupLoadingState(false)
    }
    onDidTapDelete = { [weak viewModel] in
      self.setupLoadingState(true)
      viewModel?.delete()
    }
  }
  
  // MARK: - Private Methods
  private func setupLoadingState(_ isLoading: Bool) {
    activityIndicator.isHidden = !isLoading
    isLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    deleteButton.isHidden = isLoading
  }
  
  private func setup() {
    setupCardNumberLabel()
    setupDeleteButton()
    setupActivityIndicator()
    setupSeparator()
  }
  
  private func setupCardNumberLabel() {
    addSubview(cardNumberLabel)
    cardNumberLabel.textColor = .base1
    cardNumberLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(20)
      make.centerY.equalToSuperview()
    }
  }
  
  private func setupDeleteButton() {
    addSubview(deleteButton)
    deleteButton.setImage(R.image.roundedClose(), for: .normal)
    deleteButton.addTarget(self, action: #selector(didTapDelete), for: .touchUpInside)
    deleteButton.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(20)
      make.centerY.equalToSuperview()
      make.leading.greaterThanOrEqualTo(cardNumberLabel.snp.trailing).offset(16)
      make.size.equalTo(40)
    }
  }
  
  private func setupActivityIndicator() {
    addSubview(activityIndicator)
    activityIndicator.color = .base1
    activityIndicator.snp.makeConstraints { make in
      make.center.equalTo(deleteButton)
    }
  }
  
  private func setupSeparator() {
    addSubview(separator)
    separator.backgroundColor = .shade30
    separator.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(20)
      make.bottom.equalToSuperview()
      make.height.equalTo(1)
    }
  }
}

// MARK: - Actions
private extension ProfileCardItemView {
  @objc func didTapDelete() {
    onDidTapDelete?()
  }
}
