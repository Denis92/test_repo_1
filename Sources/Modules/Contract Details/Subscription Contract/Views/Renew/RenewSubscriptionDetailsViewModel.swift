//
//  RenewSubscriptionDetailsViewModel.swift
//  ForwardLeasing
//

import Foundation

protocol RenewSubscriptionDetailsViewModelDelegate: class {
  func renewSubscriptionDetailsViewModel(_ viewModel: RenewSubscriptionDetailsViewModel,
                                         didRequestRenewSubscription subscription: BoughtSubscription,
                                         withCard card: PaymentCard, saveCard: Bool)
  func renewSubscriptionDetailsViewModel(_ viewModel: RenewSubscriptionDetailsViewModel,
                                         didRequestSelectCardFromList cardList: [PaymentCard], selectedCard: PaymentCard)
}

class RenewSubscriptionDetailsViewModel: RenewSubscriptionDetailsViewModelProtocol {
  var cardText: String? {
    return selectedCard?.title ?? R.string.paymentRegistration.newCard()
  }

  var renewButtonTitle: String? {
    return subscription.price.priceString().map { R.string.subscriptionDetails.renewButtonTitle($0) }
  }

  var onDidUpdateCardText: ((String?) -> Void)?

  weak var delegate: RenewSubscriptionDetailsViewModelDelegate?

  private let subscription: BoughtSubscription
  private let cards: [PaymentCard]
  private var selectedCard: PaymentCard?
  private var saveCard: Bool = false

  // MARK: - Init

  init(subscription: BoughtSubscription, cards: [PaymentCard]) {
    self.subscription = subscription
    self.cards = cards
    selectedCard = cards.first
  }

  // MARK: - Public Methods

  func update(card: PaymentCard?, saveCard: Bool) {
    selectedCard = card
    self.saveCard = saveCard
    onDidUpdateCardText?(cardText)
  }

  func renewScubscription() {
    guard let selectedCard = selectedCard else { return }
    delegate?.renewSubscriptionDetailsViewModel(self, didRequestRenewSubscription: subscription,
                                                withCard: selectedCard, saveCard: saveCard)
  }

  func changeCard() {
    guard let selectedCard = selectedCard else { return }
    delegate?.renewSubscriptionDetailsViewModel(self, didRequestSelectCardFromList: cards, selectedCard: selectedCard)
  }
}
