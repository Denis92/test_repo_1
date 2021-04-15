//
//  TableSectionViewModel.swift
//  ForwardLeasing
//

import Foundation

class TableSectionViewModel {
  // MARK: - Properties

  private(set) var cellViewModels: [CommonTableCellViewModel] = []

  let headerViewModel: CommonTableHeaderFooterViewModel?
  let footerViewModel: CommonTableHeaderFooterViewModel?

  var numberOfRows: Int {
    return cellViewModels.count
  }
  var lastCellViewModel: CommonTableCellViewModel? {
    return cellViewModels.last
  }
  var isEmpty: Bool {
    return cellViewModels.isEmpty
  }

  // MARK: - Init

  init(headerViewModel: CommonTableHeaderFooterViewModel? = nil, footerViewModel: CommonTableHeaderFooterViewModel? = nil) {
    self.headerViewModel = headerViewModel
    self.footerViewModel = footerViewModel
  }

  // MARK: - Additional

  func append(_ cellViewModel: CommonTableCellViewModel) {
    cellViewModels.append(cellViewModel)
  }

  func append(contentsOf sequence: [CommonTableCellViewModel]) {
    cellViewModels.append(contentsOf: sequence)
  }

  func replace(contentsOf sequence: [CommonTableCellViewModel]) {
    cellViewModels = sequence
  }

  @discardableResult
  func remove(at index: Int) -> CommonTableCellViewModel {
    return cellViewModels.remove(at: index)
  }
  
  func removeAll() {
    cellViewModels.removeAll()
  }

  func cellViewModel(forRowAt index: Int) -> CommonTableCellViewModel? {
    return cellViewModels.element(at: index)
  }

  func index(of cellViewModel: CommonTableCellViewModel & AnyObject) -> Int? {
    return cellViewModels.firstIndex { ($0 as AnyObject) === cellViewModel }
  }
}
