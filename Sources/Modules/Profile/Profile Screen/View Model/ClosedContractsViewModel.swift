//
//  ClosedContractsViewModel.swift
//  ForwardLeasing
//

import Foundation

protocol ClosedContractsViewModelDelegate: class {
  func closedContractsViewModelNeedsToLayoutSuperview(_ viewModel: ClosedContractsViewModel)
  func closedContractsViewModel(_ viewModel: ClosedContractsViewModel, didSelect leasingEntity: LeasingEntity)
}

class ClosedContractsViewModel: CommonTableCellViewModel {
  weak var delegate: ClosedContractsViewModelDelegate?
  
  let tableCellIdentifier = ClosedContractsCell.reuseIdentifier
  
  var onDidUpdate: (() -> Void)?
  
  private(set) var leasingEntities: [LeasingEntity] = []
  
  var hasData: Bool {
    return !leasingEntities.isEmpty
  }
  
  func onNeedsToLayoutSuperview() {
    delegate?.closedContractsViewModelNeedsToLayoutSuperview(self)
  }
  
  func setLeasingEntities(_ leasingEntities: [LeasingEntity]) {
    self.leasingEntities = leasingEntities
    self.onDidUpdate?()
  }
  
  func didSelect(_ leasingEntity: LeasingEntity) {
    delegate?.closedContractsViewModel(self, didSelect: leasingEntity)
  }
}
