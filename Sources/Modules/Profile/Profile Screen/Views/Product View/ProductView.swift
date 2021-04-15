//
//  ProductView.swift
//  ForwardLeasing
//

import UIKit

protocol ProductViewModelProtocol: class {
  var itemsViewModels: [StackViewItemViewModel] { get }
}

class ProductView: UIView, Configurable {
  // MARK: - Properties
  private let containerStackView = UIStackView()
  private let dataSource = StackViewDataSource()

  // MARK: - Init
  override init(frame: CGRect) {
    super.init(frame: frame)

    setup()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Configure
  func configure(with viewModel: ProductViewModelProtocol) {
    containerStackView.arrangedSubviews.forEach {
      $0.removeFromSuperview()
    }
    viewModel.itemsViewModels.forEach {
      if let view = dataSource.makeView(with: $0) {
        containerStackView.addArrangedSubview(view)
      }
    }
  }

  // MARK: - Private methods
  private func setup() {
    setupContainerStackViewView()
    setupDataSource()
  }

  private func setupContainerStackViewView() {
    addSubview(containerStackView)
    containerStackView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(20)
      make.top.bottom.equalToSuperview().inset(16)
    }
    containerStackView.axis = .vertical
    containerStackView.spacing = 12
  }

  private func setupDataSource() {
    dataSource.register(type: ProductButtonsView.self)
    dataSource.register(type: ProductInfoView.self)
    dataSource.register(type: ProductDeliveryView.self)
    dataSource.register(type: ProductStatusDescriptionView.self)
  }

}
