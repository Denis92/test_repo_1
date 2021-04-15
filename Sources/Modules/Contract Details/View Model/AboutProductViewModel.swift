//
//  AboutProductViewModel.swift
//  ForwardLeasing
//

import Foundation

struct AboutProductViewModel {
  let description: String?
}

extension AboutProductViewModel: CommonTableCellViewModel {
  var tableCellIdentifier: String {
    return AboutProductCell.reuseIdentifier
  }
}
