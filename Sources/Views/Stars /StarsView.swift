//
//  StarsView.swift
//  ForwardLeasing
//

import UIKit

protocol StarsViewModelProtocol {
  var numberOfStars: Int { get }
  var maxNumberOfStars: Int { get }
}

class StarsView: UIView, Configurable {
  // MARK: - Subviews
  private let stackView = UIStackView()
  
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
  func configure(with viewModel: StarsViewModelProtocol) {
    updateStars(with: viewModel)
  }
  
  // MARK: - Private Methods
  private func setup() {
    addSubview(stackView)
    stackView.spacing = 16
    stackView.distribution = .fillEqually
    stackView.snp.makeConstraints { make in
      make.leading.top.bottom.equalToSuperview()
      make.trailing.greaterThanOrEqualToSuperview()
    }
  }
  
  private func updateStars(with viewModel: StarsViewModelProtocol) {
    stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    let rating = viewModel.numberOfStars
    for index in 0 ..< viewModel.maxNumberOfStars {
      let starIcon = UIImageView()
      starIcon.contentMode = .scaleAspectFit
      if index < rating {
        starIcon.image = R.image.starFilled()
      } else {
        starIcon.image = R.image.starEmpty()
      }
      starIcon.snp.makeConstraints { make in
        make.size.equalTo(40)
      }
      stackView.addArrangedSubview(starIcon)
    }
  }
}
