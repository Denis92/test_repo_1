//
//  StackViewItemView.swift
//  ForwardLeasing
//

import Foundation

protocol StackViewItemView: ReuseIdentifiable {
  func configure(with viewModel: StackViewItemViewModel)
}
