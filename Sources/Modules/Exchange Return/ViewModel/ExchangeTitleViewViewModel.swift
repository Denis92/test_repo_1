//
//  ExchangeTitleViewViewModel.swift
//  ForwardLeasing
//

import UIKit

struct ExchangeReturnTitleViewModel: ExchangeReturnTitleViewModelProtocol {
  let title: String?
}

// MARK: - CommonTableCellViewModel

extension ExchangeReturnTitleViewModel: CommonTableCellViewModel {
  var tableCellIdentifier: String {
    return ExchangeReturnTitleViewCell.reuseIdentifier
  }
}

// MARK: - PaddingAddingContainerViewModel

extension ExchangeReturnTitleViewModel: PaddingAddingContainerViewModel {
  var padding: UIEdgeInsets {
    return UIEdgeInsets(top: 0, left: 20, bottom: 32, right: 20)
  }
}
