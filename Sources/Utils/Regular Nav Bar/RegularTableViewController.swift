//
//  RegularTableViewController.swift
//  ForwardLeasing
//

import UIKit

class RegularTableViewController: RegularNavBarViewController {
  // MARK: - Subviews
  override var scrollView: UIScrollView {
    return tableView
  }
  
  // MARK: - Properties
  var tableViewStyle: UITableView.Style {
    return .grouped
  }
  
  let dataSource = TableViewDataSource()
  
  private(set) lazy var tableView = UITableView(frame: .zero, style: tableViewStyle)

  // MARK: - Methods
  func setupTableView(with viewModel: CommonTableViewModel) {
    view.addSubview(tableView)
    tableView.separatorStyle = .none
    tableView.showsVerticalScrollIndicator = false
    tableView.contentInset.top = defaultTopContentInset
    tableView.register(TitleHeader.self, forHeaderFooterViewReuseIdentifier: TitleHeader.reuseIdentifier)
    tableView.register(ProfileCardCell.self, forCellReuseIdentifier: ProfileCardCell.reuseIdentifier)
    tableView.register(ProfileSettingsLinkCell.self, forCellReuseIdentifier: ProfileSettingsLinkCell.reuseIdentifier)
    tableView.snp.makeConstraints { make in
      make.top.equalTo(navigationBarView).offset(navigationBarView.titleViewMaxY)
      make.leading.trailing.bottom.equalToSuperview()
    }
    dataSource.setup(tableView: tableView, viewModel: viewModel)
    dataSource.onDidScroll = { [weak self] scrollView in
      self?.handleScrollIfNeeded(scrollView)
    }
  }
}
