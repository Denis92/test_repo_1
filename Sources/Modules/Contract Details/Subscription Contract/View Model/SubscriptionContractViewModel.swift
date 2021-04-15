//
//  SubscriptionContractViewModel.swift
//  ForwardLeasing
//

import Foundation
import PromiseKit

protocol SubscriptionContractViewModelDelegate: class {
  func subscriptionContractViewModel(_ viewModel: SubscriptionContractViewModel,
                                     didRequestRenewSubscription subscription: BoughtSubscription,
                                     withCard card: PaymentCard, saveCard: Bool)
  func subscriptionContractViewModel(_ viewModel: SubscriptionContractViewModel,
                                     didRequestSelectCardFromList cardList: [PaymentCard], selectedCard: PaymentCard)
}

class SubscriptionContractViewModel: BindableViewModel {
  typealias Dependencies = HasCardsService

  var onDidStartRequest: (() -> Void)?
  var onDidFinishRequest: (() -> Void)?
  var onDidRequestToShowErrorBanner: ((Error) -> Void)?
  var onDidRequestToShowEmptyErrorView: ((Error) -> Void)?
  var onDidLoadData: (() -> Void)?

  var onDidCopyKey: (() -> Void)?
  var onNeedsToShareKeys: ((String) -> Void)?

  var title: String {
    return subscription.name
  }

  weak var delegate: SubscriptionContractViewModelDelegate?

  let headerViewModel: SubscriptionContractHeaderViewModelProtocol
  let keysViewModel: SubscriptionKeyListViewModel
  let aboutViewModel: AboutSubscriptionDetailsViewModel

  private (set) var renewViewModel: RenewSubscriptionDetailsViewModel?

  private let subscription: BoughtSubscription
  private let dependencies: Dependencies

  init(subscription: BoughtSubscription, dependencies: Dependencies) {
    self.subscription = subscription
    self.dependencies = dependencies
    headerViewModel = SubscriptionContractHeaderViewModel(subscription: subscription)
    keysViewModel = SubscriptionKeyListViewModel(keys: subscription.keys)
    aboutViewModel = AboutSubscriptionDetailsViewModel(text: subscription.description)
    keysViewModel.delegate = self
  }

  // MARK: - Public Methods

  func loadCards() {
    guard subscription.isActive else {
      onDidLoadData?()
      return
    }
    
    onDidStartRequest?()
    firstly {
      dependencies.cardsService.getCards()
    }.ensure {
      self.onDidFinishRequest?()
    }.done { cards in
      let paymentCards = cards.map { PaymentCard.card($0) } + [.new]
      self.renewViewModel = RenewSubscriptionDetailsViewModel(subscription: self.subscription,
                                                              cards: paymentCards)
      self.renewViewModel?.delegate = self
      self.onDidLoadData?()
    }.catch { error in
      self.onDidRequestToShowEmptyErrorView?(error)
    }
  }

  func update(selectedCard: PaymentCard?, saveCard: Bool) {
    renewViewModel?.update(card: selectedCard, saveCard: saveCard)
  }
}

// MARK: - SubscriptionKeyListViewModelDelegate
extension SubscriptionContractViewModel: SubscriptionKeyListViewModelDelegate {
  func subscriptionKeyListViewModelDidCopyKey(_ viewModel: SubscriptionKeyListViewModel) {
    onDidCopyKey?()
  }

  func subscriptionKeyListViewModel(_ viewModel: SubscriptionKeyListViewModel, didRequestShareKeys keys: [String]) {
    let combinedKeys = keys.joined(separator: "\n")
    onNeedsToShareKeys?(combinedKeys)
  }
}

// MARK: - RenewSubscriptionDetailsViewModelDelegate
extension SubscriptionContractViewModel: RenewSubscriptionDetailsViewModelDelegate {
  func renewSubscriptionDetailsViewModel(_ viewModel: RenewSubscriptionDetailsViewModel,
                                         didRequestRenewSubscription subscription: BoughtSubscription,
                                         withCard card: PaymentCard, saveCard: Bool) {
    delegate?.subscriptionContractViewModel(self, didRequestRenewSubscription: subscription, withCard: card,
                                            saveCard: saveCard)
  }

  func renewSubscriptionDetailsViewModel(_ viewModel: RenewSubscriptionDetailsViewModel,
                                         didRequestSelectCardFromList cardList: [PaymentCard], selectedCard: PaymentCard) {
    
    delegate?.subscriptionContractViewModel(self, didRequestSelectCardFromList: cardList, selectedCard: selectedCard)
  }
}
