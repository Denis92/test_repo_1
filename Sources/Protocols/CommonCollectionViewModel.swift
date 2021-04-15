//
//  CommonCollectionViewModel.swift
//  ForwardLeasing
//

import Foundation

protocol CommonCollectionViewModel {
  var collectionCellViewModels: [CommonCollectionCellViewModel] { get }
  var footerViewModel: CommonCollectionHeaderFooterViewModel? { get }
}

extension CommonCollectionViewModel {
  var footerViewModel: CommonCollectionHeaderFooterViewModel? {
    return nil
  }
}
