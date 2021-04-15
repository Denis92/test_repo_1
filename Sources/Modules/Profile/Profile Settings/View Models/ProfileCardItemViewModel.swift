//
//  ProfileCardItemViewModel.swift
//  ForwardLeasing
//

import UIKit

protocol ProfileCardItemViewModelDelegate: class {
  func profileCardItemViewModel(_ viewModel: ProfileCardItemViewModel,
                                didRequestDeleteCard card: Card,
                                completion: (() -> Void)?)
}

class ProfileCardItemViewModel: CommonTableCellViewModel, ProfileCardItemViewModelProtocol {
  // MARK: - Properties
  var tableCellIdentifier: String {
    return ProfileCardCell.reuseIdentifier
  }
  
  weak var delegate: ProfileCardItemViewModelDelegate?
  
  var cardNumber: String? {
    let lastCharacters = String(card.mask.suffix(8))
    let newString  = Array(lastCharacters.reversed()
      .enumerated()
      .map { $0.offset == 4 ? "\($0.element) " : String($0.element) }
      .reversed())
    return newString.reduce("", +)
  } 
  
  var onDidFinishDelete: (() -> Void)?
  
  private let card: Card
  
  // MARK: - Init
  init(card: Card) {
    self.card = card
  }
  
  // MARK: - Public
  func delete() {
    delegate?.profileCardItemViewModel(self, didRequestDeleteCard: card) { [weak self] in
      self?.onDidFinishDelete?()
    }
  }
}
