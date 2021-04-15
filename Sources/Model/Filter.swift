//
//  Filter.swift
//  ForwardLeasing
//

import Foundation

enum FilterType {
  case singleOptionOnly, multipleOptions
}

struct Filter: Equatable {
  let filterType: FilterType
  let title: String?
  var options: [FilterOption]
}

struct FilterOption: Equatable {
  let title: String?
  var isSelected: Bool

  init(title: String?, isSelected: Bool = false) {
    self.title = title
    self.isSelected = isSelected
  }
}
