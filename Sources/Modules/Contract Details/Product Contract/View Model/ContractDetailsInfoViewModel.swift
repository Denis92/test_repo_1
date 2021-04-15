//
//  ContractDetailsInfoViewModel.swift
//  ForwardLeasing
//

import UIKit

struct ContractDetailsInfoViewModel: ContractDetailsInfoViewModelProtocol {
  let contractNumber: String?
  let productProgressImageViewModel: ProductProgressImageViewModel
  let monthPayment: String?
  let statusTitle: String?
  let statusSubtitle: String?
}
