//
//  CommonTableCellProtocol.swift
//  ForwardLeasing
//

import UIKit

protocol CommonTableCellViewModel {
  var tableCellIdentifier: String { get }
  var selectionStyle: UITableViewCell.SelectionStyle { get }
  var accessoryType: UITableViewCell.AccessoryType { get }
  var contentInsets: UIEdgeInsets { get }
  var swipeAction: UISwipeActionsConfiguration? { get }

  func selectTableCell()
  func select(deselectionClosure: (() -> Void)?)
}

extension CommonTableCellViewModel {
  func selectTableCell() {
    // do nothing by default
  }

  func select(deselectionClosure: (() -> Void)?) {
    selectTableCell()
  }

  var selectionStyle: UITableViewCell.SelectionStyle {
    return .none
  }

  var accessoryType: UITableViewCell.AccessoryType {
    return .none
  }

  var contentInsets: UIEdgeInsets {
    return .zero
  }

  var swipeAction: UISwipeActionsConfiguration? {
    return nil
  }
}

protocol CommonTableCellContainerViewModel: CommonTableCellViewModel {
  var contentViewModel: CommonTableCellViewModel { get }
}

extension CommonTableCellContainerViewModel {
  func select(deselectionClosure: (() -> Void)?) {
    contentViewModel.select(deselectionClosure: deselectionClosure)
  }
}

protocol CommonTableCell {
  func configure(with viewModel: CommonTableCellViewModel)
}
