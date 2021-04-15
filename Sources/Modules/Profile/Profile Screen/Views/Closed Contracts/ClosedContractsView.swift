//
//  ClosedContractsView.swift
//  ForwardLeasing
//

import UIKit

class ClosedContractsView: UIStackView, Configurable {
  // MARK: - Init
  
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure
  
  func configure(with viewModel: ClosedContractsViewModel) {
    update(with: viewModel)
    viewModel.onDidUpdate = { [weak self, weak viewModel] in
      guard let viewModel = viewModel else { return }
      self?.update(with: viewModel)
    }
  }
  
  // MARK: - Setup
  
  private func setup() {
    axis = .vertical
  }
  
  // MARK: - Private methods
  
  private func update(with viewModel: ClosedContractsViewModel) {
    arrangedSubviews.forEach { $0.removeFromSuperview() }
    viewModel.leasingEntities.enumerated().forEach { index, entity in
      let itemView = ClosedContractItemView()
      itemView.configure(leasingEntity: entity)
      itemView.hidesDivider = index == viewModel.leasingEntities.count - 1
      itemView.onDidTapView = { [weak viewModel] in
        viewModel?.didSelect(entity)
      }
      addArrangedSubview(itemView)
    }
  }
}
