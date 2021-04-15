//
//  ColorFilter.swift
//  ForwardLeasing
//

import UIKit

struct ColorFilter: Equatable {
  let title: String?
  var options: [ColorFilterOption]
}

struct ColorFilterOption: Equatable {
  let color: ProductColor
  var isSelected: Bool

  init(color: ProductColor, isSelected: Bool = false) {
    self.color = color
    self.isSelected = isSelected
  }
}
