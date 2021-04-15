//
//  PaymentPeriodCell.swift
//  ForwardLeasing
//

import UIKit

class PaymentPeriodCell: UICollectionViewCell, CommonCollectionCell {
  // MARK: - Outlets

  @IBOutlet private weak var dateIntervalLabel: UILabel!
  @IBOutlet private weak var sumLabel: UILabel!
  @IBOutlet private weak var periodInfoLabel: UILabel!

  // MARK: - Public methods
  func configure(with viewModel: CommonCollectionCellViewModel) {
    guard let viewModel = viewModel as? PaymentPerionCellViewModel else { return }
    dateIntervalLabel.text = viewModel.dateString
    sumLabel.text = viewModel.sumString
    periodInfoLabel.text = viewModel.paymentInformation
  }
}
