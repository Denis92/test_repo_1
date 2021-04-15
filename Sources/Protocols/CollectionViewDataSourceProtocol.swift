//
//  CollectionViewDataSourceProtocol.swift
//  ForwardLeasing
//

import UIKit

protocol CollectionViewDataSourceProtocol: UICollectionViewDataSource, UICollectionViewDelegate {
  var items: [CommonCollectionCellViewModel] { get }

  var numberOfSections: Int { get }
  func numberOfItems(in sectionIndex: Int) -> Int
  func cellIdentifier(forItemAt indexPath: IndexPath) -> String?
  func cellViewModel(forItemAt indexPath: IndexPath) -> CommonCollectionCellViewModel?
}

extension CollectionViewDataSourceProtocol {
  var numberOfSections: Int {
    return 1
  }

  func numberOfItems(in sectionIndex: Int) -> Int {
    return items.count
  }

  func cellIdentifier(forItemAt indexPath: IndexPath) -> String? {
    return cellViewModel(forItemAt: indexPath)?.collectionCellIdentifier
  }

  func cellViewModel(forItemAt indexPath: IndexPath) -> CommonCollectionCellViewModel? {
    return items.element(at: indexPath.row)
  }
}
