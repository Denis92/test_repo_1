//
//  SubscriptionCellViewModel.swift
//  ForwardLeasing
//

import UIKit

class SubscriptionCellViewModel: SubscriptionCellViewModelProtocol, CommonTableCellViewModel {
  var tableCellIdentifier: String {
    return SubscriptionCell.reuseIdentifier
  }

  let subscriptionViewModel: SubscriptionViewModel

  // TODO: - Uncomment in future releases
//  var swipeAction: UISwipeActionsConfiguration? {
//    let action = UIContextualAction(style: .normal, title: nil) { [weak self] _, _, completion in
//      self?.subscriptionViewModel.hideSubscription()
//      completion(true)
//    }
//    action.backgroundColor = .shade20
//    action.image = R.image.hideIcon()
//    return UISwipeActionsConfiguration(actions: [action])
//  }

  init(subscriptionViewModel: SubscriptionViewModel) {
    self.subscriptionViewModel = subscriptionViewModel
  }

  func selectTableCell() {
    subscriptionViewModel.selectTableCell()
  }
}
