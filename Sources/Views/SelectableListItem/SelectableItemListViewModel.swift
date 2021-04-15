//
//  SelectableItemListViewModel.swift
//  ForwardLeasing
//

import UIKit

protocol SelectableItem {
  var title: String? { get }
}

extension Subcategory: SelectableItem { }

protocol SelectableItemListViewModelDelegate: class {
  func selectableItemListViewModel<Item: SelectableItem>(_ viewModel: SelectableItemListViewModel<Item>,
                                                         didSelectItem item: Item)
  func selectableItemListViewModelDidDeselect<Item: SelectableItem>(_ viewModel: SelectableItemListViewModel<Item>)
}

class SelectableItemListViewModel<Item: SelectableItem>: SelectableItemListViewModelProtocol, CommonTableCellViewModel {
  var tableCellIdentifier: String {
    return CommonContainerTableViewCell<SelectableListItemView>.reuseIdentifier
  }
  
  var title: String? {
    return item.title
  }
  
  let textColor: UIColor
  
  var onDidSelect: (() -> Void)?

  var onDidUpdate: (() -> Void)?

  weak var delegate: SelectableItemListViewModelDelegate?

  let item: Item

  private let shouldSelect: Bool
  private (set) var isSelected: Bool
  private var onShouldUntoggle: (() -> Bool)?
  
  init(item: Item, isSelected: Bool = false, shouldSelect: Bool = true,
       textColor: UIColor = .shade70, onShouldUntoggle: (() -> Bool)? = nil,
       onDidSelect: (() -> Void)? = nil) {
    self.item = item
    self.isSelected = isSelected
    self.onDidSelect = onDidSelect
    self.shouldSelect = shouldSelect
    self.textColor = textColor
    self.onShouldUntoggle = onShouldUntoggle
  }

  func selectTableCell() {
    didTap()
  }
  
  func didTap() {
    guard shouldSelect else {
      onDidSelect?()
      return
    }
    if onShouldUntoggle?() ?? true || !isSelected {
      isSelected.toggle()
    }
    onDidUpdate?()
    if isSelected {
      delegate?.selectableItemListViewModel(self, didSelectItem: item)
    } else {
      delegate?.selectableItemListViewModelDidDeselect(self)
    }
    onDidSelect?()
  }
  
  func setSelected(_ isSelected: Bool) {
    self.isSelected = isSelected
    onDidUpdate?()
  }
}
