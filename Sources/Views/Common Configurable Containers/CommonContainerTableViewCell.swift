//
//  CommonContainerTableViewCell.swift
//  ForwardLeasing
//

import UIKit

class CommonContainerTableViewCell<ContentView: Configurable>: UITableViewCell, CommonTableCell,
  Configurable where ContentView: UIView {

  typealias ViewModel = ContentView.ViewModel
  private let configurableView: ContentView

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    configurableView = ContentView()
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    configurableView.prepareForReuse()
  }

  func configure(with viewModel: ViewModel) {
    if let cellViewModel = viewModel as? CommonTableCellViewModel {
      selectionStyle = cellViewModel.selectionStyle
      accessoryType = cellViewModel.accessoryType
      updateContentInsets(insets: cellViewModel.contentInsets)
    }
    configurableView.configure(with: viewModel)
  }

  func configure(with viewModel: CommonTableCellViewModel) {
    selectionStyle = viewModel.selectionStyle
    accessoryType = viewModel.accessoryType

    if let containedViewModel = (viewModel as? CommonTableCellContainerViewModel)?.contentViewModel,
      let contentViewModel = containedViewModel as? ContentView.ViewModel {
      configurableView.configure(with: contentViewModel)
      updateContentInsets(insets: viewModel.contentInsets)
      return
    }

    guard let viewModel = viewModel as? ContentView.ViewModel else {
      return
    }

    if let cellViewModel = viewModel as? CommonTableCellViewModel {
      updateContentInsets(insets: cellViewModel.contentInsets)
    }

    configurableView.configure(with: viewModel)
  }

  private func setup() {
    backgroundColor = superview?.backgroundColor ?? .clear
    contentView.backgroundColor = superview?.backgroundColor ?? .clear
    contentView.addSubview(configurableView)
    configurableView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }

  private func updateContentInsets(insets: UIEdgeInsets) {
    guard insets != .zero else {
      return
    }
    configurableView.snp.remakeConstraints { make in
      make.leading.equalToSuperview().offset(insets.left)
      make.trailing.equalToSuperview().inset(insets.right)
      make.top.equalToSuperview().offset(insets.top)
      make.bottom.equalToSuperview().inset(insets.bottom)
    }
  }
}
