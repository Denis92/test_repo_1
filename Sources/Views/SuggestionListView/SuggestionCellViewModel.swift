//
//  SuggestionCellViewModel.swift
//  ForwardLeasing
//

import Foundation

struct SuggestionCellViewModel: CommonTableCellViewModel {
  let tableCellIdentifier: String = SuggestionCell.reuseIdentifier
  
  let title: String
  let isFirst: Bool
  let isLast: Bool
  
  var onDidSelect: (() -> Void)?
  
  func select(deselectionClosure: (() -> Void)?) {
    onDidSelect?()
  }
}
