//
//  ProductInfoView.swift
//  ForwardLeasing
//

import UIKit

enum ImageViewType {
  case simple(_ viewModel: ProductImageViewModelProtocol)
  case progress(_ viewModel: ProductProgressImageViewModelProtocol)
}

protocol ProductInfoViewModelProtocol: class {
  var descriptionViewModel: ProductDescriptionViewModelProtocol { get }
  var imageViewType: ImageViewType { get }
}

class ProductInfoView: UIView {
  // MARK: - Properties
  private let descriptionView = ProductDescriptionView()
  private let imageContainerView = UIView()

  // MARK: - Init
  override init(frame: CGRect) {
    super.init(frame: frame)

    setup()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Configure
  func configure(with viewModel: ProductInfoViewModelProtocol) {
    descriptionView.configure(with: viewModel.descriptionViewModel)
    setupImageView(with: viewModel.imageViewType)
  }

  // MARK: - Private methods
  private func setup() {
    setupImageContainerView()
    setupDescriptionView()
  }

  private func setupImageContainerView() {
    addSubview(imageContainerView)
    imageContainerView.snp.makeConstraints { make in
      make.top.trailing.equalToSuperview()
      make.size.equalTo(122)
      make.bottom.lessThanOrEqualToSuperview().priority(999)
    }
    imageContainerView.makeRoundedCorners()
  }

  private func setupDescriptionView() {
    addSubview(descriptionView)
    descriptionView.snp.makeConstraints { make in
      make.leading.equalToSuperview()
      make.trailing.equalTo(imageContainerView.snp.leading).offset(-16)
      make.top.greaterThanOrEqualToSuperview()
      make.centerY.equalTo(imageContainerView).priority(750)
      make.bottom.lessThanOrEqualToSuperview()
    }
  }

  private func setupImageView(with imageViewType: ImageViewType) {
    imageContainerView.subviews.forEach {
      $0.removeFromSuperview()
    }
    let imageView = makeImageView(with: imageViewType)
    imageContainerView.addSubview(imageView)
    imageView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }

  private func makeImageView(with imageViewType: ImageViewType) -> UIView {
    switch imageViewType {
    case .simple(let viewModel):
      let productImageView = ProductImageView()
      setSimpleImageViewAppearance(productImageView, type: viewModel.type)
      productImageView.configure(with: viewModel)
      return productImageView
    case .progress(let viewModel):
      let productImageView = ProductProgressImageView()
      productImageView.configure(with: viewModel)
      return productImageView
    }
  }
  
  private func setSimpleImageViewAppearance(_ imageView: ProductImageView, type: ProductType) {
    switch type {
    case .smartphone, .service:
      imageView.backgroundColor = .shade20
    case .notebook, .appliances:
      imageView.layer.borderWidth = 6
      imageView.layer.borderColor = UIColor.shade20.cgColor
    }
    
    if [.notebook, .appliances, .service].contains(type) {
      imageView.setImageInset(inset: 13)
    }
  }
}

// MARK: - StackViewItemView
extension ProductInfoView: StackViewItemView {
  func configure(with viewModel: StackViewItemViewModel) {
    guard let viewModel = viewModel as? ProductInfoViewModelProtocol else {
      return
    }
    configure(with: viewModel)
  }
}
