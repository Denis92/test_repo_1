//
//  PriceListView.swift
//  ForwardLeasing
//

import UIKit

protocol PriceListViewModelProtocol {
  var items: [PriceListItemViewModel] { get }
}

class PriceListView: UIView, Configurable {
  // MARK: - Subviews
  private let stackView = UIStackView()
  
  // MARK: - Properties
  private var maxPriceWidth: CGFloat = 0 {
    didSet {
      guard oldValue != maxPriceWidth else { return }
      onDidUpdateMaxWidth?()
      setNeedsLayout()
      layoutIfNeeded()
    }
  }
  private var priceListItems: [PriceListItemView] = [] {
    didSet {
      onDidUpdateMaxWidth?()
      priceListItems.forEach {
        $0.updatePriceWidth(maxPriceWidth)
      }
    }
  }
  private var onDidUpdateMaxWidth: (() -> Void)?
  
  // MARK: - Init
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }
  
  // MARK: - Public Methods
  func configure(with viewModel: PriceListViewModelProtocol) {
    updateItems(with: viewModel.items)
  }
  
  // MARK: - Private Methods
  private func setup() {
    addSubview(stackView)
    stackView.axis = .vertical
    stackView.spacing = 10
    stackView.distribution = .fillProportionally
    stackView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  private func updateItems(with viewModels: [PriceListItemViewModel]) {
    stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    var items: [PriceListItemView] = []
    viewModels.forEach {
      let view = PriceListItemView()
      view.onDidUpdateWidth = { [weak self, weak view] in
        guard let view = view else { return }
        self?.updateMaxWidthIfNeeded(view.priceLabelWidth)
      }
      items.append(view)
      view.configure(with: $0)
      if view.priceLabelWidth > maxPriceWidth {
        maxPriceWidth = view.priceLabelWidth
      }
      stackView.addArrangedSubview(view)
    }
    priceListItems = items
  }
  
  private func updateMaxWidthIfNeeded(_ width: CGFloat) {
    if width > maxPriceWidth {
      maxPriceWidth = width
    }
  }
}
