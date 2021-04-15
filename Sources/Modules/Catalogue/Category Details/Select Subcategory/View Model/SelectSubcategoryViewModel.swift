//
//  SelectSubcategoryViewModel.swift
//  ForwardLeasing
//

import Foundation
import CoreGraphics

private extension Constants {
  static let allSubcategoryCode = UUID().uuidString
  static let rowHeight: CGFloat = 56
  static let headerHeight: CGFloat = 64
}

protocol SelectSubcategoryViewModelDelegate: class {
  func selectSubcategoryViewModel(_ viewModel: SelectSubcategoryViewModel, didSelectSubcategory subcategory: Subcategory?)
}

class SelectSubcategoryViewModel: CommonTableViewModel {
  var sectionViewModels: [TableSectionViewModel] {
    let sectionViewModel = TableSectionViewModel()
    sectionViewModel.append(contentsOf: items)
    return [sectionViewModel]
  }

  var height: CGFloat {
    let contentHeight = CGFloat(items.count) * Constants.rowHeight + Constants.headerHeight + Constants.windowSafeAreaBottomInset
    let maxHeight = Constants.maxModalScreenHeight
    return min(contentHeight, maxHeight)
  }

  var onDidSelectItem: (() -> Void)?

  weak var delegate: SelectSubcategoryViewModelDelegate?

  private var items: [SelectableItemListViewModel<Subcategory>] = []
  private var selectedSubcategory: Subcategory?
  private let allSubcategory: Subcategory

  init(subcategories: [Subcategory], selectedSubcategory: Subcategory?) {
    allSubcategory = Subcategory(code: Constants.allSubcategoryCode,
                                 title: R.string.catalogue.subcategoryListAllOptionTitle(), imageURL: nil)
    var allSubcategories = [allSubcategory]
    allSubcategories.append(contentsOf: subcategories)
    self.selectedSubcategory = selectedSubcategory
    items = allSubcategories.map {
      let isSelected = selectedSubcategory == nil ? $0.code == Constants.allSubcategoryCode : selectedSubcategory == $0
      let viewModel = SelectableItemListViewModel(item: $0, isSelected: isSelected)
      viewModel.delegate = self
      return viewModel
    }
  }
}

extension SelectSubcategoryViewModel: SelectableItemListViewModelDelegate {
  func selectableItemListViewModel<Item>(_ viewModel: SelectableItemListViewModel<Item>,
                                         didSelectItem item: Item) where Item: SelectableItem {
    guard let subcategory = item as? Subcategory else {
      return
    }

    if subcategory.code != Constants.allSubcategoryCode {
      selectedSubcategory = subcategory
    } else {
      selectedSubcategory = nil
    }

    let filteredItems = items.filter { $0.item.code != subcategory.code }
    filteredItems.forEach { $0.setSelected(false) }
    onDidSelectItem?()
    delegate?.selectSubcategoryViewModel(self, didSelectSubcategory: selectedSubcategory)
  }

  func selectableItemListViewModelDidDeselect<Item: SelectableItem>(_ viewModel: SelectableItemListViewModel<Item>) {
    viewModel.setSelected(true) // do not allow deselection
  }
}
