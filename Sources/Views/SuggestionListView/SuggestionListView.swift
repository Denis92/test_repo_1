//
//  SuggestionListView.swift
//  ForwardLeasing
//

import UIKit

class SuggestionListView: UIView {
  typealias ViewModel = CommonTableViewModel & BindableViewModel
  
  private let tableView = IntrinsicTableView()
  private let containerView = UIView()
  
  private let viewModel: ViewModel
  private let dataSource: TableViewDataSource
  
  init(viewModel: ViewModel, dataSource: TableViewDataSource = TableViewDataSource()) {
    self.viewModel = viewModel
    self.dataSource = dataSource
    super.init(frame: .zero)
    setupContainerView()
    setupTableView()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func bind() {
    viewModel.onDidFinishRequest = { [weak self] in
      self?.reloadData()
    }
  }
  
  private func setupContainerView() {
    containerView.makeRoundedCorners(radius: 4)
    addSubview(containerView)
    
    containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  private func reloadData() {
    UIView.performWithoutAnimation {
      dataSource.update(viewModel: viewModel)
      tableView.reloadData()
    }
  }
  
  private func setupTableView() {
    tableView.register(SuggestionCell.self, forCellReuseIdentifier: SuggestionCell.reuseIdentifier)
    tableView.showsVerticalScrollIndicator = false
    tableView.isScrollEnabled = false
    containerView.addSubview(tableView)
    
    tableView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    dataSource.setup(tableView: tableView, viewModel: viewModel)
    tableView.reloadData()
  }
}
