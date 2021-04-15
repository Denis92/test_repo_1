//
//  StackViewDataSource.swift
//  ForwardLeasing
//

import UIKit

class StackViewDataSource {
  typealias View = UIView & StackViewItemView
  private var types: [View.Type] = []

  func register(type: View.Type) {
    types.append(type)
  }

  func makeView(with viewModel: StackViewItemViewModel) -> View? {
    guard let type = types.first(where: { $0.reuseIdentifier == viewModel.itemViewIdentifier }) else {
      return nil
    }
    let view = type.init()
    view.configure(with: viewModel)
    return view
  }
}
