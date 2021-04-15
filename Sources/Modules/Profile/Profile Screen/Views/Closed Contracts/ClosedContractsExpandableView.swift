//
//  ClosedContractsExpandableView.swift
//  ForwardLeasing
//

import UIKit

class ClosedContractsExpandableView: UIView, Configurable {
  // MARK: - Properties
  
  private let expandableView = ExpandableView<ClosedContractsView>()
  
  // MARK: - Init
  
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure
  
  func configure(with viewModel: ClosedContractsViewModel) {
    expandableView.configure(title: R.string.profile.closedContractsSectionTitle(),
                             viewModel: viewModel)
    expandableView.onNeedsToLayoutSuperview = { [weak viewModel] in
      viewModel?.onNeedsToLayoutSuperview()
    }
  }
  
  // MARK: - Setup
  
  private func setup() {
    addSubview(expandableView)
    expandableView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}
