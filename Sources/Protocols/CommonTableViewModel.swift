//
//  CommonTableViewModel.swift
//  ForwardLeasing
//

import Foundation

protocol CommonTableViewModel {
  var sectionViewModels: [TableSectionViewModel] { get }

  var showHeaderAndFooterForEmptySection: Bool { get }
}

extension CommonTableViewModel {
  var showHeaderAndFooterForEmptySection: Bool {
    return false
  }
}
