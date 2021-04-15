//
//  ContractInfoItemViewModel.swift
//  ForwardLeasing
//

import UIKit

struct ContractInfoItemViewModel {
  let image: UIImage?
  let title: String?
  let description: String?
  
  init(type: ContractInfoItemType) {
    self.image = type.image
    self.title = type.title
    self.description = type.description
  }
}
