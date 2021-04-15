//
//  CatalogueTopCollectionViewModel.swift
//  ForwardLeasing
//

import Foundation

protocol CatalogueTopCollectionViewModelDelegate: class {
  func catalogueTopCollectionViewModel(_ viewModel: CatalogueTopCollectionViewModel,
                                       didSelectItem item: CatalogueNavigationItem)
}

class CatalogueTopCollectionViewModel: CommonCollectionViewModel {
  var collectionCellViewModels: [CommonCollectionCellViewModel] {
    return items
  }

  weak var delegate: CatalogueTopCollectionViewModelDelegate?

  private var items: [CatalogueTopCollectionElementViewModel] = []

  init(navigationItems: [CatalogueNavigationItem]) {
    items = navigationItems.map {
      var viewModel = CatalogueTopCollectionElementViewModel(navigationItem: $0)
      viewModel.delegate = self
      return viewModel
    }
  }
}

// MARK: - CatalogueTopCollectionElementViewModelDelegat

extension CatalogueTopCollectionViewModel: CatalogueTopCollectionElementViewModelDelegate {
  func catalogueTopCollectionElementViewModel(_ viewModel: CatalogueTopCollectionElementViewModel,
                                              didSelectItem item: CatalogueNavigationItem) {
    delegate?.catalogueTopCollectionViewModel(self, didSelectItem: item)
  }
}
