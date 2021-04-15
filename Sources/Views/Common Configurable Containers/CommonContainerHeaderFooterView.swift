//
//  CommonContainerHeaderFooterView.swift
//  ForwardLeasing
//

import UIKit

class CommonContainerHeaderFooterView<ContentView: Configurable>: UITableViewHeaderFooterView, CommonTableHeaderFooter,
  Configurable where ContentView: UIView {

  typealias ViewModel = ContentView.ViewModel
  private let configurableView: ContentView

  override init(reuseIdentifier: String?) {
    configurableView = ContentView()
    super.init(reuseIdentifier: reuseIdentifier)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configure(with viewModel: ContentView.ViewModel) {
    configurableView.configure(with: viewModel)
  }

  func configure(with viewModel: CommonTableHeaderFooterViewModel) {
    guard let viewModel = viewModel as? ContentView.ViewModel else {
      return
    }

    configurableView.configure(with: viewModel)
  }

  private func setup() {
    contentView.backgroundColor = superview?.backgroundColor ?? .clear
    contentView.addSubview(configurableView)
    configurableView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}
