//
//  ProductButtonsViewModel.swift
//  ForwardLeasing
//

import Foundation

protocol ProductButtonsViewModelDelegate: class {
  func productButtonsViewModel(_ productButtonsViewModel: ProductButtonsViewModel,
                               didSelectAction action: ProductButtonAction)
}

class ProductButtonsViewModel: ProductButtonsViewModelProtocol, StackViewItemViewModel {
  // MARK: - Properties
  var itemViewIdentifier: String {
    return ProductButtonsView.reuseIdentifier
  }

  let buttonsActions: [ProductButtonAction]
  
  weak var delegate: ProductButtonsViewModelDelegate?

  // MARK: - Init
  init(buttonsActions: [ProductButtonAction]) {
    self.buttonsActions = buttonsActions
  }

  // MARK: - Methods
  func select(action: ProductButtonAction) {
    delegate?.productButtonsViewModel(self,
                                      didSelectAction: action)
  }
}
