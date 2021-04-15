//
//  PaymentCard.swift
//  ForwardLeasing
//

import Foundation

private extension Constants {
  static let newCardHash = "newCard"
}

enum PaymentCard: SelectableItem {
  case card(Card)
  case new
  
  var title: String? {
    switch self {
    case .card(let card):
      return card.mask
    case .new:
      return R.string.contractDetails.newCardTitle()
    }
  }
  
  var isNew: Bool {
    return self == .new
  }
}

// MARK: - Hashable
extension PaymentCard: Hashable {
  func hash(into hasher: inout Hasher) {
    switch self {
    case .card(let card):
      hasher.combine(card.id)
    case .new:
      hasher.combine(Constants.newCardHash)
    }
  }
}

// MARK: - Equatable
extension PaymentCard: Equatable {
  static func == (lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case (.card(let lhsCard), .card(let rhsCard)):
      return lhsCard == rhsCard
    case (.new, .new):
      return true
    default:
      return false
    }
  }
}
