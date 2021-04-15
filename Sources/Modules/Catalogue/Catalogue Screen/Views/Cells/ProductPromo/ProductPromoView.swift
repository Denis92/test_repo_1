//
//  ProductPromoView.swift
//  ForwardLeasing
//

import UIKit

class ProductPromoView: UIView, Configurable {
  private var viewModel: ProductPromoViewModel?
  
  private let backgroundImage = UIImageView()
  private let foregroundImage = UIImageView()
  private let topLeftLabel = AttributedLabel(textStyle: .textRegular)
  private let topRightLabel = AttributedLabel(textStyle: .textRegular)
  private let centerLeftLabel = AttributedLabel(textStyle: .textRegular)
  private let centerRightLabel = AttributedLabel(textStyle: .textRegular)
  private let bottomLeftLabel = AttributedLabel(textStyle: .textRegular)
  private let bottomRightLabel = AttributedLabel(textStyle: .textRegular)
  
  // MARK: - Init
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure
  func configure(with viewModel: ProductPromoViewModel) {
    self.viewModel = viewModel
    backgroundImage.setImage(with: viewModel.backgroundImageURL)
    foregroundImage.setImage(with: viewModel.foregroundImageURL)
    foregroundImage.contentMode = viewModel.imageViewConfiguration.contentMode
    topLeftLabel.text = viewModel.topLeft
    topRightLabel.text = viewModel.topRight
    centerLeftLabel.text = viewModel.centerLeft
    centerRightLabel.text = viewModel.centerRight
    bottomLeftLabel.text = viewModel.bottomLeft
    bottomRightLabel.text = viewModel.bottomRight
  }
  
  // MARK: - Setup
  private func setup() {
    makeRoundedCorners(radius: 10)
    setupBackgroundImage()
    setupForegroundImage()
    setupTopLeftLabel()
    setupTopRightLabel()
    setupCenterLeftLabel()
    setupCenterRightLabel()
    setupBottomLeftLabel()
    setupBottomRightLabel()
  }
  
  private func setupBackgroundImage() {
    addSubview(backgroundImage)
    backgroundImage.makeRoundedCorners(radius: 8)
    backgroundImage.contentMode = .scaleAspectFill
    backgroundImage.snp.makeConstraints { make in
      make.height.equalTo(459)
      make.top.leading.trailing.bottom.equalToSuperview()
    }
  }
  
  private func setupForegroundImage() {
    addSubview(foregroundImage)
    foregroundImage.makeRoundedCorners(radius: 8)
    foregroundImage.contentMode = .scaleAspectFit
    foregroundImage.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(16)
      make.top.bottom.equalToSuperview().inset(40)
    }
  }
  
  private func setupTopLeftLabel() {
    addSubview(topLeftLabel)
    topLeftLabel.textColor = .base2
    topLeftLabel.snp.makeConstraints { make in
      make.leading.top.equalToSuperview().offset(10)
    }
  }
  
  private func setupTopRightLabel() {
    addSubview(topRightLabel)
    topRightLabel.textColor = .base2
    topRightLabel.textAlignment = .right
    topRightLabel.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(10)
      make.trailing.equalToSuperview().offset(-10)
      make.leading.equalTo(topLeftLabel.snp.trailing).offset(12)
      make.width.equalTo(topLeftLabel)
    }
  }
  
  private func setupCenterLeftLabel() {
    addSubview(centerLeftLabel)
    centerLeftLabel.textColor = .base2
    centerLeftLabel.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.leading.equalToSuperview().offset(10)
    }
  }
  
  private func setupCenterRightLabel() {
    addSubview(centerRightLabel)
    centerRightLabel.textColor = .base2
    centerRightLabel.textAlignment = .right
    centerRightLabel.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.trailing.equalToSuperview().offset(-10)
      make.leading.equalTo(centerLeftLabel.snp.trailing).offset(12)
      make.width.equalTo(centerLeftLabel)
    }
  }
  
  private func setupBottomLeftLabel() {
    addSubview(bottomLeftLabel)
    bottomLeftLabel.textColor = .base2
    bottomLeftLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().offset(10)
      make.bottom.equalTo(backgroundImage).offset(-10)
    }
  }
  
  private func setupBottomRightLabel() {
    addSubview(bottomRightLabel)
    bottomRightLabel.textColor = .base2
    bottomRightLabel.textAlignment = .right
    bottomRightLabel.snp.makeConstraints { make in
      make.trailing.equalToSuperview().offset(-10)
      make.bottom.equalTo(backgroundImage).offset(-10)
      make.leading.equalTo(bottomLeftLabel.snp.trailing).offset(12)
      make.width.equalTo(bottomLeftLabel)
    }
  }
  
}
