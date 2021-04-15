//
//  CatalogueTopCollectionElementViewModel.swift
//  ForwardLeasing
//

import Foundation

protocol CatalogueTopCollectionElementViewModelDelegate: class {
  func catalogueTopCollectionElementViewModel(_ viewModel: CatalogueTopCollectionElementViewModel,
                                              didSelectItem item: CatalogueNavigationItem)
}

struct CatalogueTopCollectionElementViewModel: CatalogueTopCollectionElementViewModelProtocol, CommonCollectionCellViewModel {
  private let navigationItem: CatalogueNavigationItem

  var collectionCellIdentifier: String {
    return CatalogueCollectionViewCell.reuseIdentifier
  }

  var type: CatalogueTopCollectionElementType {
    return .imageWithBackground(imageURL: navigationItem.imageURL.toURL(), backgroundColorHEX: navigationItem.colorHEX ?? "")
  }

  var title: String? {
    return navigationItem.name?.lowercasedFirstLetter()
  }

  weak var delegate: CatalogueTopCollectionElementViewModelDelegate?

  init(navigationItem: CatalogueNavigationItem) {
    self.navigationItem = navigationItem
  }

  func selectCollectionCell() {
    delegate?.catalogueTopCollectionElementViewModel(self, didSelectItem: navigationItem)
  }
}
