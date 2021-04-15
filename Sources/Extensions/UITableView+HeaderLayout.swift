//
//  UITableView+HeaderLayout.swift
//  ForwardLeasing
//

import UIKit

extension UITableView {
  func layoutTableHeaderView() {
    guard let headerView = self.tableHeaderView else { return }
    headerView.translatesAutoresizingMaskIntoConstraints = false
    
    let headerWidth = headerView.bounds.size.width
    headerView.snp.makeConstraints { make in
      make.width.equalTo(headerWidth)
    }
    headerView.layoutIfNeeded()
    
    headerView.frame.size.height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
    
    self.tableHeaderView = headerView
    headerView.snp.removeConstraints()
    headerView.translatesAutoresizingMaskIntoConstraints = true
  }
}
