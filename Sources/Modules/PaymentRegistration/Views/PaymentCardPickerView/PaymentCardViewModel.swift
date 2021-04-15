//
//  PaymentCardViewModel.swift
//  ForwardLeasing
//

import Foundation

struct PaymentCardViewModel {
  let card: PaymentCardType
  let isSelected: Bool

  var title: String {
    return card.title
  }

  var selectionIndicatorVisible: Bool {
    guard case .userCard = card else { return false }
    return isSelected
  }
}
