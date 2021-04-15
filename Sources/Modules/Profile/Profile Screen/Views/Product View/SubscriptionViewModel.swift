//
//  SubscriptionViewModel.swift
//  ForwardLeasing
//

import Foundation

class SubscriptionViewModel: ProductViewModelProtocol, CommonTableCellViewModel {
  // MARK: - Properties
  var tableCellIdentifier: String {
    return ProductCell.reuseIdentifier
  }

  var itemsViewModels: [StackViewItemViewModel] = []

  private let subscription: BoughtSubscription
  
  weak var delegate: ProfileCellViewModelsDelegate?

  // MARK: - Init
  init(subscription: BoughtSubscription,
       infoViewModel: ProductInfoViewModel,
       buttonsViewModel: ProductButtonsViewModel) {
    self.subscription = subscription
    itemsViewModels.append(infoViewModel)
    buttonsViewModel.delegate = self
    itemsViewModels.append(buttonsViewModel)
  }

  func selectTableCell() {
    delegate?.cellViewModel(self,
                            didSelect: .selectSubscription(subscription))
  }

  func hideSubscription() {
    delegate?.cellViewModel(self,
                            didSelect: .hideSubscription(subscription))
  }
}

// MARK: - ProductButtonsViewModelDelegate
extension SubscriptionViewModel: ProductButtonsViewModelDelegate {
  func productButtonsViewModel(_ productButtonsViewModel: ProductButtonsViewModel,
                               didSelectAction action: ProductButtonAction) {
    delegate?.cellViewModel(self, didSelect: .subscriptionAction(action, subscription))
  }
}
