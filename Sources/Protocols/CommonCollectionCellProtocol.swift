//
//  CommonCollectionCellProtocol.swift
//  ForwardLeasing
//

import Foundation
import CoreGraphics

protocol CommonCollectionCellViewModel {
  var collectionCellIdentifier: String { get }
  func selectCollectionCell()
}

extension CommonCollectionCellViewModel {
  func selectCollectionCell() {
    // do nothing by default
  }
}

protocol CommonCollectionCell {
  func configure(with viewModel: CommonCollectionCellViewModel)
  func setHighlighted(_ highlighted: Bool)
  func setSelected(_ selected: Bool)
}

extension CommonCollectionCell {
  func setHighlighted(_ highlighted: Bool) {
    // do nothing by default
  }

  func setSelected(_ selected: Bool) {
    // do nothing by default
  }
}

protocol CommonCollectionHeaderFooterViewModel {
  var viewIdentifier: String { get }
  var viewSize: CGSize { get }
}

protocol CommonConfigurableHeaderFooterView {
  func configure(with viewModel: CommonCollectionHeaderFooterViewModel)
}
