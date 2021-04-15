//
//  DeliveryPaymentFailedViewModel.swift
//  ForwardLeasing
//

import UIKit

struct DeliveryPaymentFailedViewModel: PaymentFailedViewModelProtocol {
  let cancelTitle: String? = R.string.deliveryProduct.cancelDeliveryButtonTitle()

  let onDidTapRepeat: (() -> Void)?
  let onDidTapCheckLater: (() -> Void)?
  var onDidTapCancel: (() -> Void)?
}
