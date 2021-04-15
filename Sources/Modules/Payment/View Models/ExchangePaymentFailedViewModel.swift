//
//  ExchangePaymentFailedViewModel.swift
//  ForwardLeasing
//

import UIKit

struct ExchangePaymentFailedViewModel: PaymentFailedViewModelProtocol {
  let cancelTitle: String? = nil
  let onDidTapRepeat: (() -> Void)?
  let onDidTapCheckLater: (() -> Void)?
  let onDidTapCancel: (() -> Void)? = nil
}
