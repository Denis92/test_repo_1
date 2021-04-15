//
//  Configurable.swift
//  ForwardLeasing
//

import Foundation

protocol Configurable {
  associatedtype ViewModel
  func configure(with viewModel: ViewModel)
  func prepareForReuse()
}

extension Configurable {
  func prepareForReuse() {
    // do nothing by default
  }
}
