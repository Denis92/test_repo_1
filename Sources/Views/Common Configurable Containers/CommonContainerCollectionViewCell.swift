//
//  CommonContainerCollectionViewCell.swift
//  ForwardLeasing
//

import UIKit

class CommonContainerCollectionViewCell<ContentView>: UICollectionViewCell where ContentView: UIView {
  let configurableView: ContentView

  override init(frame: CGRect) {
    configurableView = ContentView()
    super.init(frame: frame)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setup() {
    backgroundColor = superview?.backgroundColor ?? .clear
    contentView.backgroundColor = superview?.backgroundColor ?? .clear

    translatesAutoresizingMaskIntoConstraints = false
    contentView.translatesAutoresizingMaskIntoConstraints = false
    contentView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    contentView.addSubview(configurableView)
    configurableView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}

class CommonConfigurableCollectionViewCell<ContentView: Configurable>: CommonContainerCollectionViewCell<ContentView>, 
  CommonCollectionCell where ContentView: UIView {
  typealias ViewModel = ContentView.ViewModel

  func configure(with viewModel: CommonCollectionCellViewModel) {
    guard let configuringViewModel = viewModel as? ViewModel else {
      return
    }
    configurableView.configure(with: configuringViewModel)
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    configurableView.prepareForReuse()
  }
}
