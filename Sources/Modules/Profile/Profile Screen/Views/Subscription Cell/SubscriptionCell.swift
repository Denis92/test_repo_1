//
//  SubscriptionCell.swift
//  ForwardLeasing
//

import UIKit

protocol SubscriptionCellViewModelProtocol {
  var subscriptionViewModel: SubscriptionViewModel { get }
}

class SubscriptionCell: UITableViewCell {
  private let productView = ProductView()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setup() {
    setupProductView()
  }

  private func setupProductView() {
    contentView.addSubview(productView)
    productView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}

extension SubscriptionCell: CommonTableCell {
  func configure(with viewModel: CommonTableCellViewModel) {
    guard let viewModel = viewModel as? SubscriptionCellViewModelProtocol else {
      return
    }
    productView.configure(with: viewModel.subscriptionViewModel)
  }

}
