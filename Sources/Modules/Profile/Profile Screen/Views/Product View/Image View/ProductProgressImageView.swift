//
//  ProductProgressImageView.swift
//  ForwardLeasing
//

import UIKit
import SnapKit

protocol ProductProgressImageViewModelProtocol {
  var productImageViewModel: ProductImageViewModelProtocol { get }
  var circleProgressInfo: CircleProgressInfo { get }
  var insets: ProgressImageViewInsets { get }
}

class ProductProgressImageView: UIView {
  // MARK: - Properties
  var imageBackgroundColor: UIColor = .clear {
    didSet {
      imageBackgroundView.backgroundColor = imageBackgroundColor
    }
  }
  
  var trackColor: UIColor = .shade20 {
    didSet {
      circleProgressView.backgroundProgressColor = trackColor
    }
  }
  
  // MARK: - Subviews
  private var verticalImageViewConstraint: Constraint?
  private var horizontalImageViewConstraint: Constraint?

  private let imageBackgroundView = UIView()
  private let imageView = ProductImageView()
  private let circleProgressView = CircleProgressView()

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
    imageBackgroundView.makeRoundedCorners()
    makeRoundedCorners()
  }
  
  // MARK: - Configure
  func configure(with viewModel: ProductProgressImageViewModelProtocol) {
    imageView.configure(with: viewModel.productImageViewModel)
    circleProgressView.circleProgressInfo = viewModel.circleProgressInfo
    verticalImageViewConstraint?.update(inset: viewModel.insets.verticalInset)
    horizontalImageViewConstraint?.update(inset: viewModel.insets.horizontalInset)
  }
  
  // MARK: - Private Methods
  private func setup() {
    setupImageBackgroundView()
    setupImageView()
    setupCircleProgressView()
  }
  
  private func setupImageBackgroundView() {
    addSubview(imageBackgroundView)
    imageBackgroundView.backgroundColor = imageBackgroundColor
    imageBackgroundView.snp.makeConstraints { make in
      make.edges.equalToSuperview().inset(15)
    }
  }
  
  private func setupImageView() {
    addSubview(imageView)
    imageView.snp.makeConstraints { make in
      horizontalImageViewConstraint = make.leading.trailing.equalToSuperview().constraint
      verticalImageViewConstraint = make.top.bottom.equalToSuperview().constraint
    }
  }

  private func setupCircleProgressView() {
    addSubview(circleProgressView)
    circleProgressView.backgroundProgressColor = trackColor
    circleProgressView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }

}
