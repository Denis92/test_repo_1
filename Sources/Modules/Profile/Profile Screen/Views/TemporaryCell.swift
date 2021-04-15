//
//  TemporaryCell.swift
//  ForwardLeasing
//

import UIKit

struct TemporaryCellViewModel: CommonTableCellViewModel {
  var tableCellIdentifier: String {
    return TemporaryCell.reuseIdentifier
  }
  let title: String
  let onDidSelect: (() -> Void)?
  
  func select(deselectionClosure: (() -> Void)?) {
    onDidSelect?()
  }
}

class TemporaryCell: UITableViewCell, CommonTableCell {
  func configure(with viewModel: CommonTableCellViewModel) {
    guard let viewModel = viewModel as? TemporaryCellViewModel else {
      return
    }
    textLabel?.text = viewModel.title
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    textLabel?.text = nil
  }
}
