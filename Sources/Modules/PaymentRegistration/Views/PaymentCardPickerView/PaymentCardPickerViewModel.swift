//
//  PaymentCardPickerViewModel.swift
//  ForwardLeasing
//

import Foundation
import PromiseKit

protocol PaymentCardPickerViewModelDelegate: class {
  func paymentCardPickerViewModel(_ viewModel: PaymentCardPickerViewModel, didSelectCard card: PaymentCardType)
  func paymentCardPickerViewModel(_ viewModel: PaymentCardPickerViewModel, didReceiveError error: Error)
  func paymentCardPickerViewModelOnDidStartRequest(_ viewModel: PaymentCardPickerViewModel)
  func paymentCardPickerViewModelOnDidFinishRequest(_ viewModel: PaymentCardPickerViewModel)
}

enum PaymentCardType: Equatable {
  case new(saveCardData: Bool)
  case userCard(Card)

  var title: String {
    switch self {
    case .new:
      return R.string.paymentRegistration.newCard()
    case .userCard(let card):
      return card.mask
    }
  }
}

class PaymentCardPickerViewModel {
  typealias Dependences = HasCardsService
  // MARK: - Properties

  weak var delegate: PaymentCardPickerViewModelDelegate?

  private(set) var cardViewModels: [PaymentCardViewModel] = [] {
    didSet {
      onDidUpdateCards?()
    }
  }
  private(set) var selectedCard: PaymentCardType {
    didSet {
      onDidChangeSelectedCard?()
    }
  }
  var newCardConfigurationVisible: Bool {
    guard !isCardsRequestInProgress,
      case .new = selectedCard else {
        return false
    }
    return true
  }
  var selectedCardTitle: String {
    return selectedCard.title
  }
  var shouldSaveNewCardData: Bool {
    guard case let .new(saveCardData) = newCard else { return false }
    return saveCardData
  }

  var onDidStartRequest: (() -> Void)?
  var onDidFinishRequest: (() -> Void)?
  var onDidUpdateCards: (() -> Void)?
  var onDidChangeSelectedCard: (() -> Void)?

  private var cards: [Card] = []
  private var newCard: PaymentCardType = .new(saveCardData: false)
  private let dependences: Dependences
  private var isCardsRequestInProgress: Bool = false

  // MARK: - Init

  init(dependences: Dependences) {
    self.dependences = dependences
    self.selectedCard = newCard
  }

  // MARK: - Public methods

  func requestCards() {
    guard !isCardsRequestInProgress else { return }
    isCardsRequestInProgress = true
    onDidStartRequest?()
    delegate?.paymentCardPickerViewModelOnDidStartRequest(self)
    firstly {
      dependences.cardsService.getCards()
    }.done { cards in
      let selectedCard: PaymentCardType
      if let card = cards.first {
        selectedCard = .userCard(card)
      } else {
        selectedCard = self.newCard
      }
      self.cards = cards
      self.selectedCard = selectedCard
      self.buildCardViewModels()
      self.onDidUpdateCards?()
    }.catch { error in
      self.delegate?.paymentCardPickerViewModel(self, didReceiveError: error)
    }.finally {
      self.isCardsRequestInProgress = false
      self.onDidFinishRequest?()
      self.delegate?.paymentCardPickerViewModelOnDidFinishRequest(self)
    }
  }

  func selectCard(at index: Int) {
    guard let selectedCard = cardViewModels.element(at: index) else { return }
    self.selectedCard = selectedCard.card
    buildCardViewModels()
    onDidChangeSelectedCard?()
    delegate?.paymentCardPickerViewModel(self, didSelectCard: selectedCard.card)
  }

  func toggleCardDataSavingState() {
    var shouldSaveCardData = false
    if case let .new(saveCardData) = newCard {
      shouldSaveCardData = saveCardData
    }
    shouldSaveCardData.toggle()
    newCard = .new(saveCardData: shouldSaveCardData)
    if case .new = selectedCard {
      selectedCard = newCard
    }
    onDidChangeSelectedCard?()
  }

  // MARK: - Private methods

  private func buildCardViewModels() {
    var cardTypes: [PaymentCardType] = cards.map { .userCard($0) }
    if self.selectedCard != newCard {
      cardTypes.append(newCard)
    }
    self.cardViewModels = cardTypes.map {
      return PaymentCardViewModel(card: $0, isSelected: $0 == self.selectedCard)
    }
  }
}
