//
//  SubscriptionContractHeaderView.swift
//  ForwardLeasing
//

import UIKit

protocol SubscriptionContractHeaderViewModelProtocol {
  var imageURL: URL? { get }
  var backgroundColor: UIColor { get }
}

class SubscriptionContractHeaderView: UIView, Configurable {
  private var backgroundView = UIView()
  private var imageView = UIImageView()

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

  func configure(with viewModel: SubscriptionContractHeaderViewModelProtocol) {
    imageView.setImage(with: viewModel.imageURL)
    backgroundView.backgroundColor = viewModel.backgroundColor
  }

  // MARK: - Setup
  private func setup() {
    addBackgroundView()
    addImageView()
  }

  private func addBackgroundView() {
    addSubview(backgroundView)
    let height: CGFloat = 286
    backgroundView.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(46)
      make.centerX.bottom.equalToSuperview()
      make.size.equalTo(height)
    }
    backgroundView.makeRoundedCorners(radius: height * 0.5)
  }

  private func addImageView() {
    backgroundView.addSubview(imageView)
    imageView.snp.makeConstraints { make in
      make.size.equalTo(160)
      make.center.equalToSuperview()
    }
    imageView.contentMode = .scaleAspectFit
  }
}
