//
//  PaymentCardView.swift
//  ForwardLeasing
//

import UIKit

class PaymentCardView: NibView, Configurable {
  typealias ViewModel = PaymentCardViewModel
  // MARK: - Outlets

  @IBOutlet private weak var titleLabel: AttributedLabel! {
    didSet {
      titleLabel.change(textStyle: .bodyBold)
    }
  }
  @IBOutlet private weak var selectionIndicatorView: UIImageView!

  // MARK: - Public mathods

  func configure(with viewModel: PaymentCardViewModel) {
    titleLabel.text = viewModel.title
    selectionIndicatorView.isHidden = !viewModel.selectionIndicatorVisible
  }
}
