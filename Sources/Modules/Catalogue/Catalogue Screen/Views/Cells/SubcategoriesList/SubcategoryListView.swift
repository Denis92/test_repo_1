//
//  SubcatigoryListView.swift
//  ForwardLeasing
//

import UIKit

class SubcategoryListView: UIView, Configurable {
  private var viewModel: SubcategoryListViewModel?
  
  // MARK: - Subviews
  private let stackView = UIStackView()
  private let dividerView = UIView()
  
  // MARK: - Init
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure
  func configure(with viewModel: SubcategoryListViewModel) {
    self.viewModel = viewModel
    stackView.subviews.forEach { $0.removeFromSuperview() }
    
    for subcategory in viewModel.itemViewModels {
      let cell = SubcategoryCellView()
      cell.configure(with: subcategory)
      stackView.addArrangedSubview(cell)
    }
  }
  
  // MARK: - Setup
  private func setup() {
    setupView()
    setupStackView()
    setupDividerView()
  }
  
  private func setupView() {
    backgroundColor = .white
  }
  
  private func setupStackView() {
    addSubview(stackView)
    stackView.axis = .vertical
    stackView.distribution = .fillEqually
    stackView.snp.makeConstraints { make in
      make.top.bottom.equalToSuperview()
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }
  
  private func setupDividerView() {
    addSubview(dividerView)
    dividerView.backgroundColor = .shade40
    dividerView.snp.makeConstraints { make in
      make.leading.trailing.bottom.equalToSuperview()
      make.height.equalTo(1)
    }
  }
}
