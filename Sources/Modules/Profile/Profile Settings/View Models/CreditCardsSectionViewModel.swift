//
//  CreditCardsSectionViewModel.swift
//  ForwardLeasing
//

import Foundation

protocol CreditCardsSectionViewModelDelegate: class {
  func creditCardsSectionViewModel(_ viewModel: CreditCardsSectionViewModel,
                                   didRequestDeleteCard card: Card,
                                   completion: ((Bool) -> Void)?)
  func creditCardsSectionViewModel(_ viewModel: CreditCardsSectionViewModel, didRemoveCardAtIndex index: Int)
}

class CreditCardsSectionViewModel: TableSectionViewModel {
  // MARK: - Properties
  weak var delegate: CreditCardsSectionViewModelDelegate?
  
  private var cards: [Card]
  
  init(cards: [Card]) {
    self.cards = cards
    let headerViewModel = TitleHeaderViewModel(title: R.string.profileSettings.creditCardsTitle())
    super.init(headerViewModel: headerViewModel)
    append(contentsOf: makeCardCells(from: cards, delegate: self))
  }
  
  func makeCreditCardsSection(from cards: [Card], delegate: ProfileCardItemViewModelDelegate) -> TableSectionViewModel {
    let section = TableSectionViewModel(headerViewModel: TitleHeaderViewModel(title: R.string.profileSettings.creditCardsTitle()))
    let cells = makeCardCells(from: cards, delegate: delegate)
    section.append(contentsOf: cells)
    return section
  }
  
  private func makeCardCells(from cards: [Card], delegate: ProfileCardItemViewModelDelegate) -> [ProfileCardItemViewModel] {
    return cards.map {
      let itemViewModel = ProfileCardItemViewModel(card: $0)
      itemViewModel.delegate = delegate
      return itemViewModel
    }
  }
  
  private func removeCard(_ card: Card) {
    guard let cardIndex = cards.firstIndex(of: card) else { return }
    cards.remove(at: cardIndex)
    remove(at: cardIndex)
    delegate?.creditCardsSectionViewModel(self, didRemoveCardAtIndex: cardIndex)
  }
}

// MARK: - ProfileCardItemViewModelDelegate
extension CreditCardsSectionViewModel: ProfileCardItemViewModelDelegate {
  func profileCardItemViewModel(_ viewModel: ProfileCardItemViewModel, didRequestDeleteCard card: Card,
                                completion: (() -> Void)?) {
    delegate?.creditCardsSectionViewModel(self, didRequestDeleteCard: card) { [weak self] isRemoved in
      completion?()
      if isRemoved {
        self?.removeCard(card)
      }
    }
  }
}
