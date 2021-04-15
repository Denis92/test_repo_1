//
//  ProfileEmptyStateViewModel.swift
//  ForwardLeasing
//

import Foundation

struct ProfileEmptyStateViewModel {
  let title: String?
}

// MARK: - CommonTableCellViewModel

extension ProfileEmptyStateViewModel: CommonTableCellViewModel {
  var tableCellIdentifier: String {
    return ProfileEmptyStateCell.reuseIdentifier
  }
}
