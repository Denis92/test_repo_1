//
//  ProductImageView.swift
//  ForwardLeasing
//

import UIKit

protocol ProductImageViewModelProtocol: class {
  var imageURL: URL? { get }
  var imageViewConfiguration: ImageViewConfiguration { get }
  var type: ProductType { get }
}

class ProductImageView: UIView {
  // MARK: - Properties
  private let imageView = UIImageView()

  // MARK: - Init
  override init(frame: CGRect) {
    super.init(frame: frame)

    setup()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    makeRoundedCorners()
  }

  // MARK: - Configure
  func configure(with viewModel: ProductImageViewModelProtocol) {
    imageView.setImage(with: viewModel.imageURL)
    imageView.contentMode = viewModel.imageViewConfiguration.contentMode
  }
  
  // MARK: - Public methods
  
  func setImageInset(inset: CGFloat) {
    imageView.snp.remakeConstraints { make in
      make.edges.equalToSuperview().inset(inset)
    }
  }

  // MARK: - Private methods
  private func setup() {
    setupImageView()
  }

  private func setupImageView() {
    addSubview(imageView)
    imageView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    imageView.contentMode = .scaleAspectFit
  }
}
