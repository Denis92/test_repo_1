//
//  BottomSheetListViewModel.swift
//  ForwardLeasing
//

import UIKit

class BottomSheetListViewModel<T: SelectableItem>: CommonTableViewModel {
  // MARK: - Properties
  var sectionViewModels: [TableSectionViewModel] = []
  var selectedIndexes: IndexSet = []
  var cells: [SelectableItemListViewModel<T>] = [] {
    didSet {
      updateSection(with: cells)
    }
  }
  
  private let items: [T]
  private let type: BottomSheetListType
  
  // MARK: - Init
  init(items: [T], type: BottomSheetListType = .normal) {
    self.items = items
    self.type = type
    let cells = makeCells()
    self.cells = cells
    updateSection(with: cells)
  }
  
  // MARK: - Public
  func didSelect(item: T, at index: Int) {
    // Override
  }
  
  func finish() {
    // Override
  }
  
  func makeCells() -> [SelectableItemListViewModel<T>] {
    return items.enumerated().map { index, item -> SelectableItemListViewModel<T> in
      return SelectableItemListViewModel(item: item, isSelected: selectedIndexes.contains(index),
                                         shouldSelect: type == .selectable,
                                         textColor: .base1,
                                         onShouldUntoggle: { [weak self] in
                                          return !(self?.selectedIndexes.contains(index) ?? false)
                                         },
                                         onDidSelect: { [weak self] in
                                          self?.didSelect(item: item, at: index)
                                         })
    }
  }
  
  private func updateSection(with cells: [SelectableItemListViewModel<T>]) {
    let section = TableSectionViewModel()
    section.append(contentsOf: cells)
    sectionViewModels = [section]
  }
}
