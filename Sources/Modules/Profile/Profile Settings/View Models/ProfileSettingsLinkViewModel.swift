//
//  ProfileSettingsLinkViewModel.swift
//  ForwardLeasing
//

import UIKit

struct ProfileSettingsLinkViewModel: CommonTableCellViewModel, ProfileSettingsLinkViewModelProtocol {
  let tableCellIdentifier = ProfileSettingsLinkCell.reuseIdentifier
  
  let title: String?
  let onDidSelect: (() -> Void)?
  
  func select(deselectionClosure: (() -> Void)?) {
    onDidSelect?()
  }
}
