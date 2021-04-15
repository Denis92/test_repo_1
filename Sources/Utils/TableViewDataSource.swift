//
//  TableViewDataSource.swift
//  ForwardLeasingTests
//

import UIKit

class TableViewDataSource: NSObject, TableViewDataSourceProtocol {
  private var showHeaderAndFooterForEmptySection: Bool = false
  private (set) var sections: [TableSectionViewModel] = []

  var onDidScroll: ((UIScrollView) -> Void)?

  init(showHeaderAndFooterForEmptySection: Bool = false) {
    self.showHeaderAndFooterForEmptySection = showHeaderAndFooterForEmptySection
  }

  func setup(tableView: UITableView,
             viewModel: CommonTableViewModel) {
    tableView.dataSource = self
    tableView.delegate = self
    update(viewModel: viewModel)
  }

  func update(viewModel: CommonTableViewModel) {
    sections = viewModel.sectionViewModels
    showHeaderAndFooterForEmptySection = viewModel.showHeaderAndFooterForEmptySection
  }
}

// MARK: - Default UITableViewDataSource methods

extension TableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return numberOfSections
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return numberOfRows(in: section)
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let identifier = cellIdentifier(forRowAt: indexPath),
      let cellViewModel = cellViewModel(forRowAt: indexPath) else { return UITableViewCell() }
    let cell = tableView.dequeueReusableCell(withIdentifier: identifier,
                                             for: indexPath)
    (cell as? CommonTableCell)?.configure(with: cellViewModel)
    cell.selectionStyle = .none
    return cell
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard let headerViewModel = sections.element(at: section)?.headerViewModel,
      let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerViewModel.headerFooterReuseIdentifier) else {
      return nil
    }
    if !showHeaderAndFooterForEmptySection, (sections.element(at: section)?.numberOfRows ?? 0) == 0 {
      return nil
    }
    header.backgroundView = UIView()
    (header as? CommonTableHeaderFooter)?.configure(with: headerViewModel)
    return header
  }

  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    guard let footerViewModel = sections.element(at: section)?.footerViewModel,
      let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: footerViewModel.headerFooterReuseIdentifier) else {
      return nil
    }
    if !showHeaderAndFooterForEmptySection, (sections.element(at: section)?.numberOfRows ?? 0) == 0 {
      return nil
    }
    footer.backgroundView = UIView()
    (footer as? CommonTableHeaderFooter)?.configure(with: footerViewModel)
    return footer
  }
}

// MARK: - Default UITableViewDelegate methods

extension TableViewDataSource: UITableViewDelegate {
  func tableView(_ tableView: UITableView,
                 trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    let viewModel = cellViewModel(forRowAt: indexPath)
    return viewModel?.swipeAction
  }
  
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    let viewModel = cellViewModel(forRowAt: indexPath)
    return viewModel?.swipeAction != nil
  }
  
  func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    return []
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let viewModel = cellViewModel(forRowAt: indexPath)
    DispatchQueue.main.async {
      viewModel?.select { [weak tableView] in
        tableView?.deselectRow(at: indexPath, animated: true)
      }
    }
  }

  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell,
                 forRowAt indexPath: IndexPath) {
    let viewModel = cellViewModel(forRowAt: indexPath)
    if var cachingCellViewModel = viewModel as? CellHeightCaching,
      cachingCellViewModel.cachedHeight == nil {
      cell.layoutIfNeeded()
      cachingCellViewModel.cachedHeight = cell.frame.height
    }
  }

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    guard sections.element(at: section)?.headerViewModel != nil else {
      return CGFloat.leastNonzeroMagnitude
    }
    return UITableView.automaticDimension
  }

  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    guard sections.element(at: section)?.footerViewModel != nil else {
      return CGFloat.leastNonzeroMagnitude
    }
    return UITableView.automaticDimension
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return height(forRowAt: indexPath)
  }

  func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return height(forRowAt: indexPath)
  }

  private func height(forRowAt indexPath: IndexPath) -> CGFloat {
    let viewModel = cellViewModel(forRowAt: indexPath)
    if let cachingCellViewModel = viewModel as? CellHeightCaching,
      let height = cachingCellViewModel.cachedHeight {
      return height
    }
    return UITableView.automaticDimension
  }

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    onDidScroll?(scrollView)
  }
}
