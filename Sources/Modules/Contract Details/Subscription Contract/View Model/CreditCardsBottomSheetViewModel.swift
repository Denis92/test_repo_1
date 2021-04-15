//
//  CreditCardsBottomSheetViewModel.swift
//  ForwardLeasing
//

import Foundation

protocol CreditCardBottomSheetViewModelDelegate: class {
  func creditCardBottomSheetViewModelDidRequestHide(_ viewModel: CreditCardBottomSheetViewModel)
  func creditCardBottomSheetViewModel(_ viewModel: CreditCardBottomSheetViewModel,
                                      didFinishWithSelectedCard selectedCard: PaymentCard,
                                      saveCard: Bool)
}

class CreditCardBottomSheetViewModel: BottomSheetListViewModel<PaymentCard> {
  // MARK: - Properties
  weak var delegate: CreditCardBottomSheetViewModelDelegate?
  
  override var selectedIndexes: IndexSet {
    didSet {
      cells.enumerated().forEach { index, element in
        element.setSelected(selectedIndexes.contains(index))
      }
    }
  }
  
  private var selectedCard: PaymentCard?
  private let cards: [PaymentCard]
  
  init(cards: [PaymentCard], selectedCard: PaymentCard?) {
    self.cards = cards
    super.init(items: cards, type: .selectable)
    setSelectedCard(selectedCard)
    cells = makeCells()
  }
  
  // MARK: - Override
  override func didSelect(item: PaymentCard, at index: Int) {
    selectedCard = item
    selectOrDeselectIndex(index: index)
  }
  
  // MARK: - Private
  private func setSelectedCard(_ card: PaymentCard?) {
    self.selectedCard = card
    guard let card = card else {
      selectedIndexes.removeAll()
      return
    }
    if let selectedCardIndex = cards.firstIndex(of: card) {
      selectOrDeselectIndex(index: selectedCardIndex)
    }
  }
  
  private func selectOrDeselectIndex(index: Int) {
    selectedIndexes.removeAll()
    selectedIndexes.insert(index)
  }
}

// MARK: - CardsBottomSheetFooterViewModelProtocol

extension CreditCardBottomSheetViewModel: CardsBottomSheetFooterViewModelProtocol {
  func didTapSelectCardButton(saveCard: Bool) {
    guard let selectedCard = selectedCard else { return }
    delegate?.creditCardBottomSheetViewModel(self, didFinishWithSelectedCard: selectedCard,
                                             saveCard: saveCard)
    delegate?.creditCardBottomSheetViewModelDidRequestHide(self)
  }
}
