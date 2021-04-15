//
//  SubscriptionProductView.swift
//  ForwardLeasing
//

import UIKit

protocol SubscriprionProductViewModelProtocol: class {
  var backgroundColor: UIColor? { get }
  var name: String? { get }
  var price: String? { get }
  var imageURL: URL? { get }
  var durationViewModels: [ProductPropertyPickerItemViewModelProtocol] { get }
  var onDidUpdateSelectedItem: (() -> Void)? { get set }
  var onDidTapBuy: ((SubscriptionProductItem) -> Void)? { get }
  
  func buy()
}

class SubscriptionProductView: UIView, Configurable {
  // MARK: - Outlets
  private let topContainer = UIView()
  private let backgroundCircle = UIView()
  private let imageView = UIImageView()
  private let productPickerContainer = UIStackView()
  private let nameLabel = AttributedLabel(textStyle: .title2Bold)
  private let priceLabel = AttributedLabel(textStyle: .title2Bold)
  private let buyButton = StandardButton(type: .primary)
  
  // MARK: - Properties
  var onDidTapBuy: (() -> Void)?
  
  // MARK: - Init
  
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    backgroundCircle.makeRoundedCorners(radius: (topContainer.bounds.height - 60) / 2)
  }
  
  // MARK: - Public Methods
  
  func configure(with viewModel: SubscriprionProductViewModelProtocol) {
    update(with: viewModel)
    updateProductPicker(with: viewModel)
    viewModel.onDidUpdateSelectedItem = { [weak viewModel, weak self] in
      guard let viewModel = viewModel else { return }
      self?.update(with: viewModel)
    }
    setNeedsLayout()
    layoutIfNeeded()
  }
  
  // MARK: - Private Methods
  private func update(with viewModel: SubscriprionProductViewModelProtocol) {
    onDidTapBuy = { [weak viewModel] in
      viewModel?.buy()
    }
    backgroundCircle.backgroundColor = viewModel.backgroundColor
    imageView.setImage(with: viewModel.imageURL)
    nameLabel.text = viewModel.name
    priceLabel.text = viewModel.price
  }
  
  private func updateProductPicker(with viewModel: SubscriprionProductViewModelProtocol) {
    productPickerContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }
    viewModel.durationViewModels.forEach { durationViewModel in
      let productPickerItem = ProductPropertyPickerItemView()
      productPickerItem.configure(with: durationViewModel)
      productPickerContainer.addArrangedSubview(productPickerItem)
    }
  }
  
  private func setup() {
    setupTopContainer()
    setupBackgroundCircle()
    setupImageView()
    setupNameLabel()
    setupProductPickerContainer()
    setupPriceLabel()
    setupBuyButton()
  }
  
  private func setupTopContainer() {
    addSubview(topContainer)
    topContainer.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.leading.trailing.equalToSuperview().inset(20)
      make.height.equalTo(345)
    }
  }
  
  private func setupBackgroundCircle() {
    topContainer.addSubview(backgroundCircle)
    backgroundCircle.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(60)
      make.leading.trailing.greaterThanOrEqualToSuperview().inset(25).priority(.high)
      make.bottom.equalToSuperview()
      make.centerX.equalToSuperview()
      make.width.equalTo(backgroundCircle.snp.height)
    }
  }
  
  private func setupImageView() {
    topContainer.addSubview(imageView)
    imageView.contentMode = .scaleAspectFit
    imageView.snp.makeConstraints { make in
      make.edges.equalToSuperview().inset(32)
    }
  }
  
  private func setupNameLabel() {
    addSubview(nameLabel)
    nameLabel.textColor = .base1
    nameLabel.numberOfLines = 0
    nameLabel.textAlignment = .center
    nameLabel.snp.makeConstraints { make in
      make.top.equalTo(topContainer.snp.bottom).offset(10)
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }
  
  private func setupProductPickerContainer() {
    addSubview(productPickerContainer)
    productPickerContainer.axis = .horizontal
    productPickerContainer.distribution = .equalSpacing
    productPickerContainer.snp.makeConstraints { make in
      make.top.equalTo(nameLabel.snp.bottom).offset(10)
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }
  
  private func setupPriceLabel() {
    addSubview(priceLabel)
    priceLabel.textColor = .base1
    priceLabel.textAlignment = .center
    priceLabel.snp.makeConstraints { make in
      make.top.equalTo(productPickerContainer.snp.bottom).offset(10)
      make.leading.trailing.equalToSuperview()
    }
  }
  
  private func setupBuyButton() {
    addSubview(buyButton)
    buyButton.setTitle(R.string.common.buy(), for: .normal)
    buyButton.addTarget(self, action: #selector(didTapBuy), for: .touchUpInside)
    buyButton.snp.makeConstraints { make in
      make.top.equalTo(priceLabel.snp.bottom).offset(10)
      make.leading.trailing.bottom.equalToSuperview().inset(20)
    }
  }
  
  @objc private func didTapBuy() {
    onDidTapBuy?()
  }
}
