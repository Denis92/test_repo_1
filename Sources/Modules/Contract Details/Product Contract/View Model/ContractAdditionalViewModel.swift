//
//  ContractAdditionalViewModel.swift
//  ForwardLeasing
//

import Foundation

class ContractAdditionalViewModel<ApplicationViewModel>: CommonTableCellViewModel {
  let tableCellIdentifier: String
  let hint: String?
  let title: String
  let applicationViewModel: ApplicationViewModel

  init(title: String, hint: String?, applicationViewModel: ApplicationViewModel, tableCellIdentifier: String) {
    self.title = title
    self.hint = hint
    self.applicationViewModel = applicationViewModel
    self.tableCellIdentifier = tableCellIdentifier
  }
}
