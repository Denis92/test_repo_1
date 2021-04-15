//
//  TableViewDataSourceProtocol.swift
//  ForwardLeasing
//

import UIKit

protocol TableViewDataSourceProtocol: UITableViewDataSource {
  var sections: [TableSectionViewModel] { get }
  var onDidScroll: ((UIScrollView) -> Void)? { get }

  var numberOfSections: Int { get }
  func numberOfRows(in sectionIndex: Int) -> Int
  func cellIdentifier(forRowAt indexPath: IndexPath) -> String?
  func cellViewModel(forRowAt indexPath: IndexPath) -> CommonTableCellViewModel?
}

extension TableViewDataSourceProtocol {
  var numberOfSections: Int {
    return sections.count
  }

  func numberOfRows(in sectionIndex: Int) -> Int {
    let section = sections.element(at: sectionIndex)
    return section?.numberOfRows ?? 0
  }

  func cellIdentifier(forRowAt indexPath: IndexPath) -> String? {
    let section = sections.element(at: indexPath.section)
    let viewModel = section?.cellViewModel(forRowAt: indexPath.row)
    return viewModel?.tableCellIdentifier
  }

  func cellViewModel(forRowAt indexPath: IndexPath) -> CommonTableCellViewModel? {
    let section = sections.element(at: indexPath.section)
    return section?.cellViewModel(forRowAt: indexPath.row)
  }
}
