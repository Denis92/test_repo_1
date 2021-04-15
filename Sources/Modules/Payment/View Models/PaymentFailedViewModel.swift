//
//  PaymentFailedViewModel.swift
//  ForwardLeasing
//

import Foundation

protocol PaymentFailedViewModelDelegate: class {
  func paymentFailedViewModelDidRequestRepeatPayment(_ viewModel: PaymentFailedViewModel)
  func paymentFailedViewModelDidRequestCheckLater(_ viewModel: PaymentFailedViewModel)
}

class PaymentFailedViewModel {
  private (set) lazy var paymentFailedViewModel: PaymentFailedViewModelProtocol = makeExchangePaymentFailedViewModel()

  weak var delegate: PaymentFailedViewModelDelegate?

  private func makeExchangePaymentFailedViewModel() -> ExchangePaymentFailedViewModel {
    let onDidTapRepeat: (() -> Void) = { [weak self] in
      guard let self = self else {
        return
      }
      self.delegate?.paymentFailedViewModelDidRequestRepeatPayment(self)
    }
    let onDidTapCheckLater: (() -> Void) = { [weak self] in
      guard let self = self else {
        return
      }
      self.delegate?.paymentFailedViewModelDidRequestCheckLater(self)
    }
    return ExchangePaymentFailedViewModel(onDidTapRepeat: onDidTapRepeat, onDidTapCheckLater: onDidTapCheckLater)
  }
}
