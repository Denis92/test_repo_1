//
//  ExchangeReturnBarcodeViewModel.swift
//  ForwardLeasing
//

import UIKit

struct ExchangeReturnBarcodeViewModel: BarcodeViewModelProtocol {
  let contractNumber: String?
  let title: String?
  let contentStrings: [String]
  let additionalInfo: [String]
}

// MARK: - CommonTableCellViewModel

extension ExchangeReturnBarcodeViewModel: CommonTableCellViewModel {
  var tableCellIdentifier: String {
    return ExchangeReturnBarcodeCell.reuseIdentifier
  }
}

// MARK: - PaddingAddingContainerViewModel

extension ExchangeReturnBarcodeViewModel: PaddingAddingContainerViewModel {
  var padding: UIEdgeInsets {
    return UIEdgeInsets(top: 0, left: 20, bottom: 32, right: 20)
  }
}
