//
//  DeliveryInfoView.swift
//  ForwardLeasing
//

import UIKit

protocol DeliveryInfoViewModelProtocol: class {
  var userDataItems: [UserDataItemViewModel] { get }
  var deliveryInfoItems: [UserDataItemViewModel] { get }
  var state: DeliveryInfoViewState { get }
  
  var onDidUpdate: (() -> Void)? { get set }
}

enum DeliveryInfoViewState {
  case error
  case loading
  case normal
}

class DeliveryInfoView: UIView, Configurable {
  // MARK: - Outlets
  private let userDataStack = UIStackView()
  private let separator = UIView()
  private let deliveryInfoStack = UIStackView()
  private let activityIndicatorView = ActivityIndicatorView()
  private let unavailableDeliveryLabel = AttributedLabel(textStyle: .textRegular)
  
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
  
  func configure(with viewModel: DeliveryInfoViewModelProtocol) {
    update(with: viewModel)
    viewModel.onDidUpdate = { [weak viewModel, weak self] in
      guard let viewModel = viewModel else { return }
      self?.update(with: viewModel)
    }
  }
  
  // MARK: - Private Methods
  private func update(with viewModel: DeliveryInfoViewModelProtocol) {
    updateItems(itemsViewModel: viewModel.deliveryInfoItems, to: deliveryInfoStack)
    updateItems(itemsViewModel: viewModel.userDataItems, to: userDataStack)
    update(with: viewModel.state)
  }
  
  private func update(with state: DeliveryInfoViewState) {
    switch state {
    case .error:
      deliveryInfoStack.isHidden = true
      activityIndicatorView.isAnimating = false
      unavailableDeliveryLabel.isHidden = false
    case .loading:
      deliveryInfoStack.isHidden = true
      activityIndicatorView.isAnimating = true
      unavailableDeliveryLabel.isHidden = false
    case .normal:
      deliveryInfoStack.isHidden = false
      activityIndicatorView.isAnimating = false
      unavailableDeliveryLabel.isHidden = false
    }
  }
  
  private func setup() {
    setupUserDataStack()
    setupSeparator()
    setupDeliveryInfoStack()
    setupActivityIndicatorView()
  }
  
  private func setupUserDataStack() {
    addSubview(userDataStack)
    userDataStack.axis = .vertical
    userDataStack.spacing = 8
    userDataStack.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.leading.trailing.equalToSuperview()
    }
  }
  
  private func setupSeparator() {
    addSubview(separator)
    separator.backgroundColor = .shade30
    separator.snp.makeConstraints { make in
      make.top.equalTo(userDataStack.snp.bottom).offset(12)
      make.height.equalTo(1)
      make.leading.trailing.equalToSuperview()
    }
  }
  
  private func setupDeliveryInfoStack() {
    addSubview(deliveryInfoStack)
    deliveryInfoStack.axis = .vertical
    deliveryInfoStack.spacing = 8
    deliveryInfoStack.snp.makeConstraints { make in
      make.top.equalTo(separator.snp.bottom).offset(12)
      make.leading.trailing.equalToSuperview()
      make.bottom.equalToSuperview()
      make.height.equalTo(108)
    }
  }
  
  private func setupActivityIndicatorView() {
    addSubview(activityIndicatorView)
    activityIndicatorView.snp.makeConstraints { make in
      make.top.equalTo(deliveryInfoStack).offset(20)
      make.centerX.equalToSuperview()
    }
  }
  
  private func setupUnavailableDeliveryLabel() {
    addSubview(unavailableDeliveryLabel)
    unavailableDeliveryLabel.textColor = .error
    unavailableDeliveryLabel.numberOfLines = 0
    unavailableDeliveryLabel.text = R.string.deliveryProduct.selectDeliveryAddressUnavailableError()
    unavailableDeliveryLabel.snp.makeConstraints { make in
      make.top.equalTo(separator.snp.bottom).offset(16)
      make.leading.trailing.equalToSuperview()
      make.bottom.greaterThanOrEqualToSuperview().inset(32)
    }
    unavailableDeliveryLabel.isHidden = true
  }
  
  private func updateItems(itemsViewModel: [UserDataItemViewModel],
                           to stackView: UIStackView) {
    stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    itemsViewModel.forEach {
      let itemView = UserDataItemView()
      itemView.configure(with: $0)
      stackView.addArrangedSubview(itemView)
    }
  }
}
